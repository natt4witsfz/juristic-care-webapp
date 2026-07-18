import { authenticatedUser, clients, corsHeaders, json, sha256 } from '../_shared/http.ts';

const maximumBytes = 52_428_800;

function text(value: unknown, name: string): string {
  if (typeof value !== 'string' || !value.trim()) throw new Error(`${name} is required.`);
  return value.trim();
}

function hasExpectedSignature(mediaType: string, bytes: Uint8Array): boolean {
  const ascii = (start: number, end: number) =>
    new TextDecoder('ascii').decode(bytes.slice(start, end));
  if (mediaType === 'image/jpeg')
    return bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
  if (mediaType === 'image/png') return ascii(1, 4) === 'PNG';
  if (mediaType === 'image/webp') return ascii(0, 4) === 'RIFF' && ascii(8, 12) === 'WEBP';
  if (mediaType === 'application/pdf') return ascii(0, 5) === '%PDF-';
  if (mediaType === 'video/mp4' || mediaType === 'audio/mp4') return ascii(4, 8) === 'ftyp';
  if (mediaType === 'audio/mpeg')
    return ascii(0, 3) === 'ID3' || (bytes[0] === 0xff && (bytes[1] ?? 0) >= 0xe0);
  if (mediaType === 'text/plain') return !bytes.includes(0);
  return false;
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS')
    return new Response(null, { status: 204, headers: corsHeaders(request) });
  if (request.method !== 'POST') return json(request, { error: 'Method not allowed.' }, 405);
  try {
    const { userClient, serviceClient } = clients(request);
    const user = await authenticatedUser(userClient);
    const body = (await request.json()) as Record<string, unknown>;
    const juristicPersonId = text(body.juristicPersonId, 'juristicPersonId');
    const uploadId = text(body.uploadId, 'uploadId');
    const targetType = text(body.targetType, 'targetType');
    const targetId = text(body.targetId, 'targetId');

    const { data: account, error: accountError } = await serviceClient
      .schema('iam')
      .from('user_accounts')
      .select('person_id,account_state')
      .eq('juristic_person_id', juristicPersonId)
      .eq('auth_user_id', user.id)
      .single();
    if (accountError || !account || account.account_state !== 'active')
      throw new Error('The active O83 account could not be resolved.');

    const { data: upload, error: uploadError } = await serviceClient
      .schema('evidence')
      .from('upload_attachments')
      .select(
        'id,storage_bucket,storage_object_key,original_filename,media_type,byte_size,expected_digest,uploader_person_id,upload_state,scan_state',
      )
      .eq('juristic_person_id', juristicPersonId)
      .eq('upload_id', uploadId)
      .single();
    if (uploadError || !upload || upload.uploader_person_id !== account.person_id)
      throw new Error('The issued Evidence upload is not owned by this account.');
    if (upload.upload_state !== 'initiated' || upload.scan_state !== 'pending')
      throw new Error('The Evidence upload is not pending processing.');
    if (Number(upload.byte_size) > maximumBytes)
      throw new Error('Evidence exceeds the trusted processor limit.');

    const { data: blob, error: downloadError } = await serviceClient.storage
      .from(upload.storage_bucket)
      .download(upload.storage_object_key);
    if (downloadError || !blob) throw new Error('Private Evidence intake bytes could not be read.');
    const bytes = new Uint8Array(await blob.arrayBuffer());
    const observedDigest = await sha256(bytes);
    const eicar = new TextDecoder().decode(bytes).includes('EICAR-STANDARD-ANTIVIRUS-TEST-FILE');
    const failure =
      bytes.byteLength !== Number(upload.byte_size)
        ? 'Observed byte size differs from the issued intent.'
        : observedDigest !== upload.expected_digest
          ? 'Observed SHA-256 differs from the issued intent.'
          : !hasExpectedSignature(upload.media_type, bytes)
            ? 'File signature does not match the declared media type.'
            : eicar
              ? 'Malware test signature detected.'
              : null;
    if (failure) {
      await serviceClient.schema('api').rpc('quarantine_evidence_upload', {
        p_juristic_person_id: juristicPersonId,
        p_upload_id: uploadId,
        p_observed_digest: observedDigest,
        p_reason: failure,
      });
      return json(request, { upload_id: uploadId, state: 'quarantined', reason: failure }, 422);
    }

    const originalKey = `${juristicPersonId}/${uploadId}/${upload.original_filename}`;
    const { error: originalError } = await serviceClient.storage
      .from('o83-evidence-originals')
      .upload(originalKey, bytes, { contentType: upload.media_type, upsert: false });
    if (originalError)
      throw new Error(`Private original promotion failed: ${originalError.message}`);

    const { data: promoted, error: promoteError } = await serviceClient
      .schema('api')
      .rpc('promote_evidence_upload', {
        p_juristic_person_id: juristicPersonId,
        p_upload_id: uploadId,
        p_original_object_key: originalKey,
        p_observed_digest: observedDigest,
        p_observed_byte_size: bytes.byteLength,
        p_observed_media_type: upload.media_type,
        p_target_type: targetType,
        p_target_id: targetId,
        p_evidence_type: text(body.evidenceType, 'evidenceType'),
        p_link_role: 'related',
        p_relevance: text(body.relevance, 'relevance'),
        p_capture_method: text(body.captureMethod, 'captureMethod'),
        p_captured_at:
          typeof body.capturedAt === 'string' ? body.capturedAt : new Date().toISOString(),
        p_source_device: typeof body.sourceDevice === 'string' ? body.sourceDevice : null,
        p_custodian_relationship_id:
          typeof body.custodianRelationshipId === 'string' && body.custodianRelationshipId
            ? body.custodianRelationshipId
            : null,
      });
    if (promoteError) {
      await serviceClient.storage.from('o83-evidence-originals').remove([originalKey]);
      throw new Error(`Evidence metadata promotion failed: ${promoteError.message}`);
    }
    await serviceClient.storage.from(upload.storage_bucket).remove([upload.storage_object_key]);
    return json(request, promoted);
  } catch (error) {
    return json(
      request,
      { error: error instanceof Error ? error.message : 'Evidence processing failed.' },
      400,
    );
  }
});
