import { authenticatedUser, clients, corsHeaders, json, sha256 } from '../_shared/http.ts';

function text(value: unknown, name: string): string {
  if (typeof value !== 'string' || !value.trim()) throw new Error(`${name} is required.`);
  return value.trim();
}

async function projection(client: ReturnType<typeof clients>['userClient'], view: string) {
  const { data, error } = await client.schema('api').from(view).select('*');
  if (error) throw new Error(`Unable to export ${view}: ${error.message}`);
  return data ?? [];
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS')
    return new Response(null, { status: 204, headers: corsHeaders(request) });
  if (request.method !== 'POST') return json(request, { error: 'Method not allowed.' }, 405);
  try {
    const { userClient, serviceClient } = clients(request);
    await authenticatedUser(userClient);
    const body = (await request.json()) as Record<string, unknown>;
    const action = text(body.action, 'action');
    const juristicPersonId = text(body.juristicPersonId, 'juristicPersonId');
    const custodianRelationshipId = text(body.custodianRelationshipId, 'custodianRelationshipId');
    const scopeDefinition =
      typeof body.scopeDefinition === 'object' && body.scopeDefinition ? body.scopeDefinition : {};
    const manifestType =
      action === 'export' ? (body.reportCode ? 'report_snapshot' : 'export') : 'import_validation';
    const { data: intent, error: intentError } = await userClient
      .schema('api')
      .rpc('begin_memory_transfer', {
        p_juristic_person_id: juristicPersonId,
        p_manifest_type: manifestType,
        p_scope_definition: scopeDefinition,
        p_custodian_relationship_id: custodianRelationshipId,
      });
    if (intentError) throw new Error(`Memory transfer was not authorized: ${intentError.message}`);
    const manifestId = text((intent as Record<string, unknown>).manifest_id, 'manifest_id');
    const objectKey = text((intent as Record<string, unknown>).object_key, 'object_key');

    let archive: Record<string, unknown>;
    if (action === 'export') {
      const viewNames = [
        'current_cases',
        'current_incidents',
        'operation_workspace',
        'evidence_register',
        'decision_evolution',
        'operational_truth',
        'current_knowledge',
        'responsibility_chain',
        'aggregate_timeline',
      ] as const;
      const values = await Promise.all(viewNames.map((view) => projection(userClient, view)));
      archive = {
        format: 'o83-organizational-memory',
        version: 1,
        juristicPersonId,
        asOf: new Date().toISOString(),
        scopeDefinition,
        projections: Object.fromEntries(viewNames.map((view, index) => [view, values[index]])),
      };
    } else if (action === 'import_validation') {
      const encoded = text(body.archiveBase64, 'archiveBase64');
      const bytes = Uint8Array.from(atob(encoded), (character) => character.charCodeAt(0));
      if (bytes.byteLength > 20_000_000)
        throw new Error('Memory import validation is limited to 20 MB per artifact.');
      archive = JSON.parse(new TextDecoder().decode(bytes)) as Record<string, unknown>;
      if (
        archive.format !== 'o83-organizational-memory' ||
        archive.version !== 1 ||
        archive.juristicPersonId !== juristicPersonId
      )
        throw new Error('Memory artifact format, version, or juristic-person identity is invalid.');
    } else throw new Error('Unsupported Memory transfer action.');

    const bytes = new TextEncoder().encode(JSON.stringify(archive));
    const contentDigest = await sha256(bytes);
    const projections = (archive.projections ?? {}) as Record<string, unknown>;
    const items = await Promise.all(
      Object.entries(projections).map(async ([name, value]) => ({
        source_type: `projection:${name}`,
        source_version: '1',
        object_reference: `manifest:${manifestId}#${name}`,
        content_digest: await sha256(new TextEncoder().encode(JSON.stringify(value))),
        retention_state: 'manifested',
        verification_result: 'passed',
      })),
    );
    const { error: uploadError } = await serviceClient.storage
      .from('o83-memory-archive')
      .upload(objectKey, bytes, { contentType: 'application/json', upsert: false });
    if (uploadError)
      throw new Error(`Private Memory archive upload failed: ${uploadError.message}`);
    const { data: finalized, error: finalizeError } = await serviceClient
      .schema('api')
      .rpc('finalize_memory_transfer', {
        p_juristic_person_id: juristicPersonId,
        p_manifest_id: manifestId,
        p_object_key: objectKey,
        p_content_digest: contentDigest,
        p_items: items,
        p_verification_result: 'passed',
        p_report_code:
          typeof body.reportCode === 'string' && body.reportCode ? body.reportCode : null,
        p_period_start: typeof body.periodStart === 'string' ? body.periodStart : null,
        p_period_end: typeof body.periodEnd === 'string' ? body.periodEnd : null,
      });
    if (finalizeError) {
      await serviceClient.storage.from('o83-memory-archive').remove([objectKey]);
      throw new Error(`Memory manifest finalization failed: ${finalizeError.message}`);
    }
    return json(request, finalized);
  } catch (error) {
    return json(
      request,
      { error: error instanceof Error ? error.message : 'Memory transfer failed.' },
      400,
    );
  }
});
