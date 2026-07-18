import { getSupabaseClient } from '../../lib/supabase/client';
import type {
  AnnouncementSummary,
  CaseSummary,
  CommandParameters,
  CreatedCase,
  DashboardData,
  DeadlineSummary,
  DomainGateway,
  EvidenceUploadInput,
  EvidenceUploadResult,
  IncidentSummary,
  OperationSummary,
  OrganizationChartEntry,
  ProjectionRow,
} from './types';

type Row = Record<string, unknown>;

function text(row: Row, key: string): string {
  return String(row[key] ?? '');
}

async function loadView(view: string): Promise<Row[]> {
  const { data, error } = await getSupabaseClient().schema('api').from(view).select('*');
  if (error) throw new Error(`Unable to load ${view}: ${error.message}`);
  return (data ?? []) as Row[];
}

async function execute(command: string, parameters: CommandParameters): Promise<unknown> {
  const { data, error } = await getSupabaseClient()
    .schema('api')
    .rpc(command, parameters as Record<string, never>);
  if (error) throw new Error(`Unable to execute ${command}: ${error.message}`);
  return data;
}

async function sha256(file: File): Promise<string> {
  const bytes = await file.arrayBuffer();
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return [...new Uint8Array(digest)].map((value) => value.toString(16).padStart(2, '0')).join('');
}

async function uploadEvidence(input: EvidenceUploadInput): Promise<EvidenceUploadResult> {
  if (!input.targetId || !input.file.name || input.file.size < 1) {
    throw new Error('Evidence target and a non-empty file are required.');
  }
  const expectedDigest = await sha256(input.file);
  const intent = (await execute('begin_evidence_upload', {
    p_juristic_person_id: input.juristicPersonId,
    p_target_type: input.targetType,
    p_target_id: input.targetId,
    p_original_filename: input.file.name,
    p_media_type: input.file.type || 'application/octet-stream',
    p_byte_size: input.file.size,
    p_expected_digest: expectedDigest,
  })) as Row;
  const bucket = text(intent, 'bucket');
  const objectKey = text(intent, 'object_key');
  const uploadId = text(intent, 'upload_id');
  const { error: uploadError } = await getSupabaseClient()
    .storage.from(bucket)
    .upload(objectKey, input.file, { contentType: input.file.type, upsert: false });
  if (uploadError)
    throw new Error(`Unable to upload private Evidence intake: ${uploadError.message}`);
  const { data, error } = await getSupabaseClient().functions.invoke('evidence-process', {
    body: {
      juristicPersonId: input.juristicPersonId,
      uploadId,
      targetType: input.targetType,
      targetId: input.targetId,
      evidenceType: input.evidenceType,
      relevance: input.relevance,
      captureMethod: input.captureMethod,
      capturedAt: input.capturedAt,
      sourceDevice: input.sourceDevice ?? null,
      custodianRelationshipId: input.custodianRelationshipId ?? null,
    },
  });
  if (error) throw new Error(`Evidence processing failed: ${error.message}`);
  const result = data as Row;
  return {
    uploadId,
    evidenceItemId: text(result, 'evidence_item_id'),
    state: text(result, 'state'),
  };
}

export const supabaseDomainGateway: DomainGateway = {
  async loadDashboard(): Promise<DashboardData> {
    const [caseRows, incidentRows, operationRows, announcementRows, deadlineRows, chartRows] =
      await Promise.all([
        loadView('current_cases'),
        loadView('current_incidents'),
        loadView('operation_queue'),
        loadView('active_announcements'),
        loadView('open_compliance_deadlines'),
        loadView('organization_chart'),
      ]);
    const cases: CaseSummary[] = caseRows.map((row) => ({
      id: text(row, 'id'),
      caseNumber: text(row, 'case_number'),
      currentState: text(row, 'current_state'),
      currentSummary: row.current_summary == null ? null : String(row.current_summary),
      openedAt: text(row, 'opened_at'),
    }));
    const incidents: IncidentSummary[] = incidentRows.map((row) => ({
      id: text(row, 'id'),
      incidentNumber: text(row, 'incident_number'),
      currentState: text(row, 'current_state'),
      currentSummary: row.current_summary == null ? null : String(row.current_summary),
    }));
    const operations: OperationSummary[] = operationRows.map((row) => ({
      id: text(row, 'id'),
      operationNumber: text(row, 'operation_number'),
      title: text(row, 'title'),
      currentState: text(row, 'current_state'),
    }));
    const announcements: AnnouncementSummary[] = announcementRows.map((row) => ({
      id: text(row, 'id'),
      title: text(row, 'title'),
      body: text(row, 'body'),
      severity: text(row, 'severity'),
      acknowledgementRequired: Boolean(row.acknowledgement_required),
    }));
    const deadlines: DeadlineSummary[] = deadlineRows.map((row) => ({
      id: text(row, 'id'),
      title: text(row, 'title'),
      dueAt: text(row, 'due_at'),
      currentState: text(row, 'current_state'),
    }));
    const organization: OrganizationChartEntry[] = chartRows.map((row) => ({
      personId: text(row, 'person_id'),
      displayName: text(row, 'display_name'),
      roleCode: text(row, 'role_code'),
      roleName: text(row, 'role_name'),
    }));
    return { cases, incidents, operations, announcements, deadlines, organization };
  },
  async loadProjection(view: string): Promise<readonly ProjectionRow[]> {
    return loadView(view);
  },
  execute,
  async invokeTrustedWorkflow(name, body) {
    const { data, error } = await getSupabaseClient().functions.invoke(name, { body });
    if (error) throw new Error(`Unable to run ${name}: ${error.message}`);
    return data;
  },
  async createCase(input): Promise<CreatedCase> {
    const row = (await execute('create_case', {
      p_juristic_person_id: input.juristicPersonId,
      p_channel: input.channel,
      p_submitted_text: input.submittedText,
      p_submitted_location_text: input.submittedLocationText ?? null,
      p_occurred_at: input.occurredAt ?? null,
    })) as Row;
    return {
      caseId: text(row, 'case_id'),
      caseNumber: text(row, 'case_number'),
      reportId: text(row, 'report_id'),
    };
  },
  async createInvestigation(juristicPersonId, caseId, question) {
    const row = (await execute('create_investigation', {
      p_juristic_person_id: juristicPersonId,
      p_case_id: caseId,
      p_question: question,
    })) as Row;
    return {
      investigationId: text(row, 'investigation_id'),
      investigationNumber: text(row, 'investigation_number'),
    };
  },
  uploadEvidence,
};
