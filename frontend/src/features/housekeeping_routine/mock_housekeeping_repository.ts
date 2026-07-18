import {
  createDemoState,
  DEMO_DATE,
  DEMO_SNAPSHOT_TIME,
  HISTORICAL_DEMO_DATE,
} from './housekeeping_seed';
import type { HousekeepingRoutineRepository } from './housekeeping_repository';
import type {
  ApproveTaskInput,
  DailyBoardData,
  DailyBoardRow,
  DailyReport,
  DailyTaskInstance,
  DemoState,
  EmployeeProfile,
  EvidenceRevision,
  PositionAssignment,
  PositionHistoryData,
  RejectTaskInput,
  ReopenTaskInput,
  ResubmitTaskInput,
  TaskAuditEntry,
  TaskInspectionDetail,
} from './housekeeping_types';

export const HOUSEKEEPING_DEMO_STORAGE_KEY = 'o83.housekeeping_routine.mock.v0_1';

function cloneState(state: DemoState): DemoState {
  return JSON.parse(JSON.stringify(state)) as DemoState;
}

function findRequired<T>(items: readonly T[], predicate: (item: T) => boolean, label: string): T {
  const item = items.find(predicate);
  if (!item) throw new Error(`ไม่พบข้อมูลจำลอง: ${label}`);
  return item;
}

function employeeById(state: DemoState, employeeId: string): EmployeeProfile {
  return findRequired(
    state.employees,
    (employee) => employee.employee_id === employeeId,
    `employee ${employeeId}`,
  );
}

function activeAssignment(state: DemoState, positionId: string, date: string): PositionAssignment {
  return findRequired(
    state.assignments,
    (assignment) =>
      assignment.position_id === positionId &&
      assignment.effective_from <= date &&
      (assignment.effective_to === null || assignment.effective_to >= date),
    `assignment ${positionId} @ ${date}`,
  );
}

function nowIso() {
  return new Date().toISOString();
}

function countStatus(tasks: readonly DailyTaskInstance[], status: DailyTaskInstance['status']) {
  return tasks.filter((task) => task.status === status).length;
}

export class MockHousekeepingRoutineRepository implements HousekeepingRoutineRepository {
  private state: DemoState;

  constructor(
    private readonly storage: Storage | null = MockHousekeepingRoutineRepository.browserStorage(),
  ) {
    this.state = this.loadState();
  }

  private static browserStorage(): Storage | null {
    if (typeof window === 'undefined') return null;
    return window.localStorage;
  }

  private loadState(): DemoState {
    const raw = this.storage?.getItem(HOUSEKEEPING_DEMO_STORAGE_KEY);
    if (!raw) return createDemoState();
    try {
      const parsed = JSON.parse(raw) as DemoState;
      return parsed.version === '0.1' ? parsed : createDemoState();
    } catch {
      return createDemoState();
    }
  }

  private persist(state: DemoState) {
    this.state = cloneState(state);
    this.storage?.setItem(HOUSEKEEPING_DEMO_STORAGE_KEY, JSON.stringify(this.state));
  }

  private replaceTask(
    taskId: string,
    update: (task: DailyTaskInstance) => DailyTaskInstance,
    auditEntry: TaskAuditEntry,
    evidenceUpdate?: (items: readonly EvidenceRevision[]) => readonly EvidenceRevision[],
  ): DailyTaskInstance {
    const currentTask = findRequired(
      this.state.tasks,
      (task) => task.task_instance_id === taskId,
      `task ${taskId}`,
    );
    const updatedTask = update(currentTask);
    const nextEvidence = evidenceUpdate
      ? {
          ...this.state.evidence_revisions,
          [taskId]: evidenceUpdate(this.state.evidence_revisions[taskId] ?? []),
        }
      : this.state.evidence_revisions;
    this.persist({
      ...this.state,
      tasks: this.state.tasks.map((task) =>
        task.task_instance_id === taskId ? updatedTask : task,
      ),
      evidence_revisions: nextEvidence,
      audit_history: {
        ...this.state.audit_history,
        [taskId]: [...(this.state.audit_history[taskId] ?? []), auditEntry],
      },
    });
    return updatedTask;
  }

  async getDailyBoard(date: string): Promise<DailyBoardData> {
    const tasks = this.state.tasks.filter((task) => task.work_date === date);
    if (tasks.length === 0) throw new Error('วันที่นี้ไม่มีในชุด DEMO DATA');
    const rows: DailyBoardRow[] = this.state.positions.map((position) => {
      const assignment = activeAssignment(this.state, position.position_id, date);
      const attendance =
        this.state.attendance.find(
          (item) => item.position_id === position.position_id && item.work_date === date,
        ) ?? null;
      const actualEmployee = attendance
        ? employeeById(this.state, attendance.actual_employee_id)
        : null;
      const rowTasks = tasks
        .filter((task) => task.position_id === position.position_id)
        .map((task) => ({
          ...task,
          template: findRequired(
            this.state.templates,
            (template) => template.task_template_id === task.task_template_id,
            `template ${task.task_template_id}`,
          ),
          has_evidence: (this.state.evidence_revisions[task.task_instance_id]?.length ?? 0) > 0,
        }));
      return {
        position,
        assignment,
        contract_employee: employeeById(this.state, assignment.employee_id),
        attendance,
        actual_employee: actualEmployee,
        tasks: rowTasks,
      };
    });
    return Promise.resolve({
      date,
      snapshot_time:
        date === DEMO_DATE ? DEMO_SNAPSHOT_TIME : `${HISTORICAL_DEMO_DATE}T20:00:00+07:00`,
      available_dates: [DEMO_DATE, HISTORICAL_DEMO_DATE],
      task_templates: this.state.templates,
      rows,
      summary: {
        contract_positions: rows.length,
        checked_in: rows.filter((row) => row.attendance !== null).length,
        substitutes: rows.filter((row) => row.attendance?.worker_type === 'substitute').length,
        total_tasks: tasks.length,
        approved: countStatus(tasks, 'approved'),
        awaiting_inspection: countStatus(tasks, 'awaiting_inspection'),
        in_progress: countStatus(tasks, 'in_progress'),
        rejected: countStatus(tasks, 'rejected'),
        overdue: countStatus(tasks, 'overdue'),
      },
    });
  }

  async getTaskInspection(taskId: string): Promise<TaskInspectionDetail> {
    const task = findRequired(
      this.state.tasks,
      (item) => item.task_instance_id === taskId,
      `task ${taskId}`,
    );
    const position = findRequired(
      this.state.positions,
      (item) => item.position_id === task.position_id,
      `position ${task.position_id}`,
    );
    const assignment = activeAssignment(this.state, position.position_id, task.work_date);
    const attendance =
      this.state.attendance.find(
        (item) => item.position_id === position.position_id && item.work_date === task.work_date,
      ) ?? null;
    return Promise.resolve({
      task,
      template: findRequired(
        this.state.templates,
        (item) => item.task_template_id === task.task_template_id,
        `template ${task.task_template_id}`,
      ),
      position,
      assignment,
      contract_employee: employeeById(this.state, assignment.employee_id),
      attendance,
      actual_employee: attendance ? employeeById(this.state, attendance.actual_employee_id) : null,
      evidence_revisions: this.state.evidence_revisions[taskId] ?? [],
      audit_history: this.state.audit_history[taskId] ?? [],
    });
  }

  async approveTask(input: ApproveTaskInput): Promise<DailyTaskInstance> {
    const task = findRequired(
      this.state.tasks,
      (item) => item.task_instance_id === input.task_id,
      `task ${input.task_id}`,
    );
    if (task.status !== 'awaiting_inspection' || task.decision !== null) {
      throw new Error('งานนี้ถูกตัดสินแล้วหรือไม่ได้อยู่ในสถานะรอตรวจ');
    }
    const decidedAt = nowIso();
    return Promise.resolve(
      this.replaceTask(
        input.task_id,
        (current) => ({
          ...current,
          status: 'approved',
          inspected_at: decidedAt,
          inspected_by: input.inspector.full_name,
          rejection_reason: null,
          decision: {
            decision: 'approved',
            decided_at: decidedAt,
            decided_by: input.inspector.full_name,
            decided_by_role: input.inspector.role,
            note: input.note,
            rejection_reasons: [],
            rejection_other_detail: null,
          },
        }),
        {
          audit_id: `audit-${input.task_id}-${Date.now()}`,
          action: 'approved',
          actor_name: input.inspector.full_name,
          actor_role: input.inspector.role,
          recorded_at: decidedAt,
          detail: input.note ?? 'อนุมัติงานจากหลักฐาน DEMO',
          previous_status: 'awaiting_inspection',
          current_status: 'approved',
        },
        (items) =>
          items.map((item, index) =>
            index === items.length - 1 ? { ...item, outcome: 'approved' } : item,
          ),
      ),
    );
  }

  async rejectTask(input: RejectTaskInput): Promise<DailyTaskInstance> {
    if (input.reasons.length === 0) throw new Error('กรุณาเลือกเหตุผลอย่างน้อยหนึ่งรายการ');
    if (input.reasons.includes('อื่น ๆ') && !input.other_detail?.trim()) {
      throw new Error('กรุณาระบุรายละเอียดสำหรับเหตุผล “อื่น ๆ”');
    }
    const task = findRequired(
      this.state.tasks,
      (item) => item.task_instance_id === input.task_id,
      `task ${input.task_id}`,
    );
    if (task.status !== 'awaiting_inspection' || task.decision !== null) {
      throw new Error('งานนี้ถูกตัดสินแล้วหรือไม่ได้อยู่ในสถานะรอตรวจ');
    }
    const decidedAt = nowIso();
    const reasonText = [...input.reasons, input.other_detail?.trim() ?? '']
      .filter(Boolean)
      .join(' · ');
    return Promise.resolve(
      this.replaceTask(
        input.task_id,
        (current) => ({
          ...current,
          status: 'rejected',
          inspected_at: decidedAt,
          inspected_by: input.inspector.full_name,
          rejection_reason: reasonText,
          revision_number: current.revision_number + 1,
          decision: {
            decision: 'rejected',
            decided_at: decidedAt,
            decided_by: input.inspector.full_name,
            decided_by_role: input.inspector.role,
            note: null,
            rejection_reasons: [...input.reasons],
            rejection_other_detail: input.other_detail,
          },
        }),
        {
          audit_id: `audit-${input.task_id}-${Date.now()}`,
          action: 'rejected',
          actor_name: input.inspector.full_name,
          actor_role: input.inspector.role,
          recorded_at: decidedAt,
          detail: reasonText,
          previous_status: 'awaiting_inspection',
          current_status: 'rejected',
        },
        (items) =>
          items.map((item, index) =>
            index === items.length - 1 ? { ...item, outcome: 'rejected' } : item,
          ),
      ),
    );
  }

  async reopenTask(input: ReopenTaskInput): Promise<DailyTaskInstance> {
    if (input.inspector.role !== 'building_manager') {
      throw new Error('เฉพาะ Building Manager เท่านั้นที่ Reopen ได้ใน Mockup');
    }
    if (!input.reason.trim()) throw new Error('กรุณาระบุเหตุผลในการ Reopen');
    const task = findRequired(
      this.state.tasks,
      (item) => item.task_instance_id === input.task_id,
      `task ${input.task_id}`,
    );
    if (task.status !== 'approved' && task.status !== 'rejected') {
      throw new Error('Reopen ได้เฉพาะงานที่ถูกตัดสินแล้ว');
    }
    const reopenedAt = nowIso();
    return Promise.resolve(
      this.replaceTask(
        input.task_id,
        (current) => ({
          ...current,
          status: 'awaiting_inspection',
          inspected_at: null,
          inspected_by: null,
          rejection_reason: null,
          decision: null,
        }),
        {
          audit_id: `audit-${input.task_id}-${Date.now()}`,
          action: 'reopened',
          actor_name: input.inspector.full_name,
          actor_role: input.inspector.role,
          recorded_at: reopenedAt,
          detail: input.reason.trim(),
          previous_status: task.status,
          current_status: 'awaiting_inspection',
        },
        (items) =>
          items.map((item, index) =>
            index === items.length - 1 ? { ...item, outcome: 'submitted' } : item,
          ),
      ),
    );
  }

  async resubmitTask(input: ResubmitTaskInput): Promise<DailyTaskInstance> {
    const task = findRequired(
      this.state.tasks,
      (item) => item.task_instance_id === input.task_id,
      `task ${input.task_id}`,
    );
    if (task.status !== 'rejected') throw new Error('ส่งแก้ไขได้เฉพาะงานที่ถูกปฏิเสธ');
    const submittedAt = input.move_to === 'awaiting_inspection' ? nowIso() : null;
    const currentRevisions = this.state.evidence_revisions[input.task_id] ?? [];
    const previousPhotos = currentRevisions.at(-1)?.photos ?? [];
    return Promise.resolve(
      this.replaceTask(
        input.task_id,
        (current) => ({
          ...current,
          status: input.move_to,
          submitted_at: submittedAt,
          inspected_at: null,
          inspected_by: null,
          rejection_reason: null,
          decision: null,
        }),
        {
          audit_id: `audit-${input.task_id}-${Date.now()}`,
          action: 'resubmitted',
          actor_name: input.actor_name,
          actor_role: 'housekeeper',
          recorded_at: submittedAt ?? nowIso(),
          detail:
            input.move_to === 'awaiting_inspection'
              ? `ส่งแก้ไข revision ${task.revision_number}`
              : `เริ่มแก้ไข revision ${task.revision_number}`,
          previous_status: 'rejected',
          current_status: input.move_to,
        },
        (items) => [
          ...items,
          {
            revision_number: task.revision_number,
            submitted_at: submittedAt,
            note: 'หลักฐานชุดใหม่จำลอง โดยเก็บ revision เดิมไว้ครบถ้วน',
            photos: previousPhotos.map((photo) => ({
              ...photo,
              photo_id: `${photo.photo_id}-revision-${task.revision_number}`,
            })),
            outcome: input.move_to === 'awaiting_inspection' ? 'submitted' : 'draft',
          },
        ],
      ),
    );
  }

  async getPositionHistory(positionId: string, asOfDate: string): Promise<PositionHistoryData> {
    const position = findRequired(
      this.state.positions,
      (item) => item.position_id === positionId,
      `position ${positionId}`,
    );
    const currentAssignment = activeAssignment(this.state, positionId, asOfDate);
    return Promise.resolve({
      position,
      as_of_date: asOfDate,
      current_assignment: currentAssignment,
      current_employee: employeeById(this.state, currentAssignment.employee_id),
      assignments: this.state.assignments
        .filter((item) => item.position_id === positionId)
        .sort((a, b) => b.effective_from.localeCompare(a.effective_from))
        .map((item) => ({ ...item, employee: employeeById(this.state, item.employee_id) })),
      audit_history: this.state.audit_history[`position:${positionId}`] ?? [],
    });
  }

  async getDailyReport(date: string): Promise<DailyReport> {
    const board = await this.getDailyBoard(date);
    const tasks = board.rows.flatMap((row) => row.tasks);
    const substitutes = board.rows.flatMap((row) => {
      if (row.attendance?.worker_type !== 'substitute' || !row.actual_employee) return [];
      return [
        {
          position_code: row.position.position_code,
          contract_employee_name: row.contract_employee.full_name,
          actual_employee_name: row.actual_employee.full_name,
          reason: row.attendance.substitute_reason ?? '-',
        },
      ];
    });
    return {
      report_id: `housekeeping-report-${date}`,
      work_date: date,
      snapshot_time: `${date}T20:00:00+07:00`,
      contract_positions: board.summary.contract_positions,
      workers_present: board.summary.checked_in,
      substitutes,
      total_tasks: board.summary.total_tasks,
      approved_tasks: board.summary.approved,
      awaiting_inspection_tasks: board.summary.awaiting_inspection,
      rejected_tasks: board.summary.rejected,
      not_started_tasks: countStatus(tasks, 'not_started'),
      overdue_tasks: board.summary.overdue,
      unresolved_defects: tasks
        .filter((task) => task.status === 'rejected' || task.status === 'overdue')
        .map((task) => {
          const row = findRequired(
            board.rows,
            (item) => item.position.position_id === task.position_id,
            `board row ${task.position_id}`,
          );
          return {
            task_id: task.task_instance_id,
            position_code: row.position.position_code,
            task_name: task.template.task_name,
            status: task.status,
            reasons:
              task.decision?.rejection_reasons ??
              (task.status === 'overdue' ? ['เกินเวลาที่กำหนดและยังไม่ส่งงาน'] : []),
            inspector_name: task.inspected_by,
          };
        }),
    };
  }

  async resetDemoData(): Promise<void> {
    this.persist(createDemoState());
    return Promise.resolve();
  }
}
