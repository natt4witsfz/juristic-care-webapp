import { getSupabaseClient } from '../../lib/supabase/client';
import type {
  AnnouncementSummary,
  CaseSummary,
  CreatedCase,
  DashboardData,
  DeadlineSummary,
  DomainGateway,
  IncidentSummary,
  OperationSummary,
  OrganizationChartEntry,
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
  async createCase(input): Promise<CreatedCase> {
    const { data, error } = await getSupabaseClient()
      .schema('api')
      .rpc('create_case', {
        p_juristic_person_id: input.juristicPersonId,
        p_channel: input.channel,
        p_submitted_text: input.submittedText,
        p_submitted_location_text: input.submittedLocationText ?? null,
        p_occurred_at: input.occurredAt ?? null,
      });
    if (error) throw new Error(`Unable to create Case: ${error.message}`);
    const row = data as Row;
    return {
      caseId: text(row, 'case_id'),
      caseNumber: text(row, 'case_number'),
      reportId: text(row, 'report_id'),
    };
  },
  async createInvestigation(juristicPersonId, caseId, question) {
    const { data, error } = await getSupabaseClient().schema('api').rpc('create_investigation', {
      p_juristic_person_id: juristicPersonId,
      p_case_id: caseId,
      p_question: question,
    });
    if (error) throw new Error(`Unable to create Investigation: ${error.message}`);
    const row = data as Row;
    return {
      investigationId: text(row, 'investigation_id'),
      investigationNumber: text(row, 'investigation_number'),
    };
  },
};
