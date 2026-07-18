export type ProjectionRow = Readonly<Record<string, unknown>>;
export type CommandParameters = Readonly<Record<string, unknown>>;

export interface CaseSummary {
  readonly id: string;
  readonly caseNumber: string;
  readonly currentState: string;
  readonly currentSummary: string | null;
  readonly openedAt: string;
}

export interface IncidentSummary {
  readonly id: string;
  readonly incidentNumber: string;
  readonly currentState: string;
  readonly currentSummary: string | null;
}

export interface OperationSummary {
  readonly id: string;
  readonly operationNumber: string;
  readonly title: string;
  readonly currentState: string;
}

export interface AnnouncementSummary {
  readonly id: string;
  readonly title: string;
  readonly body: string;
  readonly severity: string;
  readonly acknowledgementRequired: boolean;
}

export interface DeadlineSummary {
  readonly id: string;
  readonly title: string;
  readonly dueAt: string;
  readonly currentState: string;
}

export interface OrganizationChartEntry {
  readonly personId: string;
  readonly displayName: string;
  readonly roleCode: string;
  readonly roleName: string;
}

export interface DashboardData {
  readonly cases: readonly CaseSummary[];
  readonly incidents: readonly IncidentSummary[];
  readonly operations: readonly OperationSummary[];
  readonly announcements: readonly AnnouncementSummary[];
  readonly deadlines: readonly DeadlineSummary[];
  readonly organization: readonly OrganizationChartEntry[];
}

export interface CreateCaseInput {
  readonly juristicPersonId: string;
  readonly channel:
    | 'resident_form'
    | 'juristic_staff_intake'
    | 'technician_finding'
    | 'security_report'
    | 'external_authority'
    | 'system_recommendation';
  readonly submittedText: string;
  readonly submittedLocationText?: string;
  readonly occurredAt?: string;
}

export interface CreatedCase {
  readonly caseId: string;
  readonly caseNumber: string;
  readonly reportId: string;
}

export interface EvidenceUploadInput {
  readonly juristicPersonId: string;
  readonly targetType: 'case' | 'investigation' | 'incident' | 'operation' | 'workstep';
  readonly targetId: string;
  readonly file: File;
  readonly evidenceType: string;
  readonly relevance: string;
  readonly captureMethod: string;
  readonly capturedAt: string;
  readonly sourceDevice?: string;
  readonly custodianRelationshipId?: string;
}

export interface EvidenceUploadResult {
  readonly uploadId: string;
  readonly evidenceItemId: string;
  readonly state: string;
}

export interface DomainGateway {
  loadDashboard(): Promise<DashboardData>;
  loadProjection(view: string): Promise<readonly ProjectionRow[]>;
  execute(command: string, parameters: CommandParameters): Promise<unknown>;
  invokeTrustedWorkflow(name: string, body: CommandParameters): Promise<unknown>;
  createCase(input: CreateCaseInput): Promise<CreatedCase>;
  createInvestigation(
    juristicPersonId: string,
    caseId: string,
    question: string,
  ): Promise<{ investigationId: string; investigationNumber: string }>;
  uploadEvidence(input: EvidenceUploadInput): Promise<EvidenceUploadResult>;
}
