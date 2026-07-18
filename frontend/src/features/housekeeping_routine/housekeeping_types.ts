export type TaskStatus =
  | 'not_due'
  | 'not_started'
  | 'in_progress'
  | 'awaiting_inspection'
  | 'approved'
  | 'rejected'
  | 'overdue';

export type WorkerType = 'regular' | 'substitute';
export type InspectorRole = 'juristic_staff' | 'building_manager';

export interface ContractPosition {
  readonly position_id: string;
  readonly position_code: string;
  readonly position_name: string;
  readonly responsibility_area: string;
  readonly building: string;
  readonly active_status: boolean;
}

export interface EmployeeProfile {
  readonly employee_id: string;
  readonly employee_code: string;
  readonly full_name: string;
  readonly profile_photo: string;
  readonly contractor_company: string;
  readonly active_status: boolean;
}

export interface PositionAssignment {
  readonly assignment_id: string;
  readonly position_id: string;
  readonly employee_id: string;
  readonly effective_from: string;
  readonly effective_to: string | null;
  readonly company_document_reference: string;
  readonly company_document_date: string;
  readonly recorded_at: string;
  readonly recorded_by: string;
  readonly is_retroactive: boolean;
  readonly retroactive_reason: string | null;
}

export interface DailyAttendance {
  readonly attendance_id: string;
  readonly work_date: string;
  readonly position_id: string;
  readonly contract_employee_id: string;
  readonly actual_employee_id: string;
  readonly worker_type: WorkerType;
  readonly substitute_reason: string | null;
  readonly check_in_photo: string;
  readonly check_in_time: string;
  readonly check_out_photo: string | null;
  readonly check_out_time: string | null;
}

export interface RoutineTaskTemplate {
  readonly task_template_id: string;
  readonly task_name: string;
  readonly location: string;
  readonly scheduled_start_time: string;
  readonly scheduled_end_time: string;
  readonly requires_before_photo: true;
  readonly requires_after_photo: true;
  readonly active_status: boolean;
}

export interface TaskDecision {
  readonly decision: 'approved' | 'rejected';
  readonly decided_at: string;
  readonly decided_by: string;
  readonly decided_by_role: InspectorRole;
  readonly note: string | null;
  readonly rejection_reasons: readonly string[];
  readonly rejection_other_detail: string | null;
}

export interface DailyTaskInstance {
  readonly task_instance_id: string;
  readonly work_date: string;
  readonly position_id: string;
  readonly task_template_id: string;
  readonly scheduled_start_time: string;
  readonly scheduled_end_time: string;
  readonly status: TaskStatus;
  readonly submitted_at: string | null;
  readonly inspected_at: string | null;
  readonly inspected_by: string | null;
  readonly rejection_reason: string | null;
  readonly revision_number: number;
  readonly performer_note: string | null;
  readonly decision: TaskDecision | null;
}

export interface EvidencePhoto {
  readonly photo_id: string;
  readonly kind: 'before' | 'after';
  readonly asset_key: string;
  readonly captured_at: string;
  readonly alt_text: string;
}

export interface EvidenceRevision {
  readonly revision_number: number;
  readonly submitted_at: string | null;
  readonly note: string;
  readonly photos: readonly EvidencePhoto[];
  readonly outcome: 'submitted' | 'rejected' | 'approved' | 'draft';
}

export interface TaskAuditEntry {
  readonly audit_id: string;
  readonly action:
    'submitted' | 'approved' | 'rejected' | 'reopened' | 'resubmitted' | 'assignment_recorded';
  readonly actor_name: string;
  readonly actor_role: string;
  readonly recorded_at: string;
  readonly detail: string;
  readonly previous_status: TaskStatus | null;
  readonly current_status: TaskStatus | null;
}

export interface InspectorUser {
  readonly inspector_id: string;
  readonly full_name: string;
  readonly role: InspectorRole;
  readonly role_label: string;
  readonly permissions: readonly ['inspect_contractor_work'];
}

export interface BoardTaskCell extends DailyTaskInstance {
  readonly template: RoutineTaskTemplate;
  readonly has_evidence: boolean;
}

export interface DailyBoardRow {
  readonly position: ContractPosition;
  readonly assignment: PositionAssignment;
  readonly contract_employee: EmployeeProfile;
  readonly attendance: DailyAttendance | null;
  readonly actual_employee: EmployeeProfile | null;
  readonly tasks: readonly BoardTaskCell[];
}

export interface DailyBoardSummary {
  readonly contract_positions: number;
  readonly checked_in: number;
  readonly substitutes: number;
  readonly total_tasks: number;
  readonly approved: number;
  readonly awaiting_inspection: number;
  readonly in_progress: number;
  readonly rejected: number;
  readonly overdue: number;
}

export interface DailyBoardData {
  readonly date: string;
  readonly snapshot_time: string;
  readonly available_dates: readonly string[];
  readonly task_templates: readonly RoutineTaskTemplate[];
  readonly rows: readonly DailyBoardRow[];
  readonly summary: DailyBoardSummary;
}

export interface TaskInspectionDetail {
  readonly task: DailyTaskInstance;
  readonly template: RoutineTaskTemplate;
  readonly position: ContractPosition;
  readonly assignment: PositionAssignment;
  readonly contract_employee: EmployeeProfile;
  readonly attendance: DailyAttendance | null;
  readonly actual_employee: EmployeeProfile | null;
  readonly evidence_revisions: readonly EvidenceRevision[];
  readonly audit_history: readonly TaskAuditEntry[];
}

export interface ApproveTaskInput {
  readonly task_id: string;
  readonly inspector: InspectorUser;
  readonly note: string | null;
}

export interface RejectTaskInput {
  readonly task_id: string;
  readonly inspector: InspectorUser;
  readonly reasons: readonly string[];
  readonly other_detail: string | null;
}

export interface ReopenTaskInput {
  readonly task_id: string;
  readonly inspector: InspectorUser;
  readonly reason: string;
}

export interface ResubmitTaskInput {
  readonly task_id: string;
  readonly actor_name: string;
  readonly move_to: 'in_progress' | 'awaiting_inspection';
}

export interface PositionHistoryData {
  readonly position: ContractPosition;
  readonly as_of_date: string;
  readonly current_assignment: PositionAssignment;
  readonly current_employee: EmployeeProfile;
  readonly assignments: readonly (PositionAssignment & { readonly employee: EmployeeProfile })[];
  readonly audit_history: readonly TaskAuditEntry[];
}

export interface DailyReportDefect {
  readonly task_id: string;
  readonly position_code: string;
  readonly task_name: string;
  readonly status: TaskStatus;
  readonly reasons: readonly string[];
  readonly inspector_name: string | null;
}

export interface DailyReport {
  readonly report_id: string;
  readonly work_date: string;
  readonly snapshot_time: string;
  readonly contract_positions: number;
  readonly workers_present: number;
  readonly substitutes: readonly {
    readonly position_code: string;
    readonly contract_employee_name: string;
    readonly actual_employee_name: string;
    readonly reason: string;
  }[];
  readonly total_tasks: number;
  readonly approved_tasks: number;
  readonly awaiting_inspection_tasks: number;
  readonly rejected_tasks: number;
  readonly not_started_tasks: number;
  readonly overdue_tasks: number;
  readonly unresolved_defects: readonly DailyReportDefect[];
}

export interface StoredReport {
  readonly stored_report_id: string;
  readonly stored_at: string;
  readonly path: string;
  readonly provider: 'mock';
}

export interface DemoState {
  readonly version: '0.1';
  readonly positions: readonly ContractPosition[];
  readonly employees: readonly EmployeeProfile[];
  readonly assignments: readonly PositionAssignment[];
  readonly attendance: readonly DailyAttendance[];
  readonly templates: readonly RoutineTaskTemplate[];
  readonly tasks: readonly DailyTaskInstance[];
  readonly evidence_revisions: Readonly<Record<string, readonly EvidenceRevision[]>>;
  readonly audit_history: Readonly<Record<string, readonly TaskAuditEntry[]>>;
}
