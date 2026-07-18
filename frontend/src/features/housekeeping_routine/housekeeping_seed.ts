import type {
  ContractPosition,
  DailyAttendance,
  DailyTaskInstance,
  DemoState,
  EmployeeProfile,
  EvidenceRevision,
  InspectorUser,
  PositionAssignment,
  RoutineTaskTemplate,
  TaskAuditEntry,
  TaskDecision,
  TaskStatus,
} from './housekeeping_types';

export const DEMO_DATE = '2026-07-18';
export const HISTORICAL_DEMO_DATE = '2026-06-15';
export const DEMO_SNAPSHOT_TIME = '2026-07-18T14:30:00+07:00';

export const DEMO_INSPECTORS: readonly InspectorUser[] = [
  {
    inspector_id: 'inspector-01',
    full_name: 'กมลชนก เดโม',
    role: 'juristic_staff',
    role_label: 'Juristic Staff',
    permissions: ['inspect_contractor_work'],
  },
  {
    inspector_id: 'inspector-02',
    full_name: 'ธนา เดโม',
    role: 'juristic_staff',
    role_label: 'Juristic Staff',
    permissions: ['inspect_contractor_work'],
  },
  {
    inspector_id: 'inspector-03',
    full_name: 'ปาริชาติ เดโม',
    role: 'juristic_staff',
    role_label: 'Juristic Staff',
    permissions: ['inspect_contractor_work'],
  },
  {
    inspector_id: 'inspector-04',
    full_name: 'วรพล เดโม',
    role: 'juristic_staff',
    role_label: 'Juristic Staff',
    permissions: ['inspect_contractor_work'],
  },
  {
    inspector_id: 'inspector-05',
    full_name: 'ศิริพร เดโม',
    role: 'building_manager',
    role_label: 'Building Manager',
    permissions: ['inspect_contractor_work'],
  },
];

export const REJECTION_REASONS = [
  'พื้นที่ยังไม่สะอาด',
  'รูป Before ไม่ชัดเจน',
  'รูป After ไม่ชัดเจน',
  'รูปไม่ตรงกับพื้นที่',
  'หลักฐานไม่ครบ',
  'ปฏิบัติงานไม่ครบตามมาตรฐาน',
  'อื่น ๆ',
] as const;

const positions: readonly ContractPosition[] = [
  ['HK-01', 'Lobby อาคาร A', 'Lobby และโถงรับรอง', 'อาคาร A'],
  ['HK-02', 'Lobby อาคาร B', 'Lobby และโถงรับรอง', 'อาคาร B'],
  ['HK-03', 'อาคาร A ชั้น 2–10', 'โถงลิฟต์และทางเดิน', 'อาคาร A'],
  ['HK-04', 'อาคาร B ชั้น 2–10', 'โถงลิฟต์และทางเดิน', 'อาคาร B'],
  ['HK-05', 'พื้นที่ส่วนกลาง', 'Clubhouse และสวนส่วนกลาง', 'ส่วนกลาง'],
  ['HK-06', 'ห้องน้ำส่วนกลาง', 'ห้องน้ำและจุดล้างมือ', 'ส่วนกลาง'],
  ['HK-07', 'ลานจอดรถ', 'ลานจอดรถและทางลาด', 'อาคาร A/B'],
  ['HK-08', 'ห้องขยะทุกชั้น', 'ห้องขยะและจุดพักขยะ', 'อาคาร A'],
  ['HK-09', 'สระว่ายน้ำและฟิตเนส', 'พื้นที่นันทนาการ', 'ส่วนกลาง'],
  ['HK-10', 'สำนักงานนิติบุคคล', 'สำนักงานและห้องประชุม', 'สำนักงาน'],
].map(([positionCode, positionName, responsibilityArea, building], index) => ({
  position_id: `position-${String(index + 1).padStart(2, '0')}`,
  position_code: positionCode ?? '',
  position_name: positionName ?? '',
  responsibility_area: responsibilityArea ?? '',
  building: building ?? '',
  active_status: true,
}));

const employeeSeed = [
  ['DEMO-HK-001', 'มณี เดโม'],
  ['DEMO-HK-002', 'สุดา เดโม'],
  ['DEMO-HK-003A', 'อรุณี เดโม'],
  ['DEMO-HK-003B', 'เบญจา เดโม'],
  ['DEMO-HK-004', 'อัญชลี เดโม'],
  ['DEMO-HK-005', 'จันทร์เพ็ญ เดโม'],
  ['DEMO-HK-006', 'ราตรี เดโม'],
  ['DEMO-HK-007', 'วิภา เดโม'],
  ['DEMO-HK-008', 'สมใจ เดโม'],
  ['DEMO-HK-009', 'นภาพร เดโม'],
  ['DEMO-HK-010', 'อรทัย เดโม'],
  ['DEMO-SUB-01', 'พรทิพย์ ทดแทนเดโม'],
  ['DEMO-HK-003C', 'สายฝน เดโม'],
  ['DEMO-HK-005A', 'พิมพา เดโม'],
] as const;

const employees: readonly EmployeeProfile[] = employeeSeed.map(
  ([employeeCode, fullName], index) => ({
    employee_id: `employee-${String(index + 1).padStart(2, '0')}`,
    employee_code: employeeCode,
    full_name: fullName,
    profile_photo: `demo://profile/${employeeCode.toLowerCase()}`,
    contractor_company: 'บริษัท ฟรอสต์เบิร์ก เซอร์วิส เดโม จำกัด',
    active_status: true,
  }),
);

const templates: readonly RoutineTaskTemplate[] = [
  {
    task_template_id: 'template-lobby',
    task_name: 'ทำความสะอาด Lobby',
    location: 'Lobby / โถงรับรอง',
    scheduled_start_time: '08:00',
    scheduled_end_time: '10:00',
    requires_before_photo: true,
    requires_after_photo: true,
    active_status: true,
  },
  {
    task_template_id: 'template-trash-am',
    task_name: 'เก็บขยะ รอบเช้า',
    location: 'แต่ละชั้น / จุดพักขยะ',
    scheduled_start_time: '08:00',
    scheduled_end_time: '09:00',
    requires_before_photo: true,
    requires_after_photo: true,
    active_status: true,
  },
  {
    task_template_id: 'template-trash-room',
    task_name: 'ทำความสะอาดห้องขยะ',
    location: 'ห้องขยะประจำอาคาร',
    scheduled_start_time: '10:00',
    scheduled_end_time: '11:00',
    requires_before_photo: true,
    requires_after_photo: true,
    active_status: true,
  },
  {
    task_template_id: 'template-trash-noon',
    task_name: 'เก็บขยะ รอบกลางวัน',
    location: 'แต่ละชั้น / จุดพักขยะ',
    scheduled_start_time: '12:00',
    scheduled_end_time: '13:00',
    requires_before_photo: true,
    requires_after_photo: true,
    active_status: true,
  },
  {
    task_template_id: 'template-common',
    task_name: 'ทำความสะอาดพื้นที่ส่วนกลาง',
    location: 'พื้นที่ตามตำแหน่งสัญญา',
    scheduled_start_time: '13:00',
    scheduled_end_time: '15:00',
    requires_before_photo: true,
    requires_after_photo: true,
    active_status: true,
  },
  {
    task_template_id: 'template-trash-pm',
    task_name: 'เก็บขยะ รอบเย็น',
    location: 'แต่ละชั้น / จุดพักขยะ',
    scheduled_start_time: '16:00',
    scheduled_end_time: '17:00',
    requires_before_photo: true,
    requires_after_photo: true,
    active_status: true,
  },
];

function assignment(
  id: string,
  positionIndex: number,
  employeeIndex: number,
  effectiveFrom: string,
  effectiveTo: string | null,
  options: { readonly retroactive?: boolean; readonly reason?: string } = {},
): PositionAssignment {
  return {
    assignment_id: id,
    position_id: `position-${String(positionIndex).padStart(2, '0')}`,
    employee_id: `employee-${String(employeeIndex).padStart(2, '0')}`,
    effective_from: effectiveFrom,
    effective_to: effectiveTo,
    company_document_reference: `FB-DEMO-${id.toUpperCase()}`,
    company_document_date: options.retroactive ? '2026-05-16' : effectiveFrom,
    recorded_at: options.retroactive
      ? '2026-05-18T10:20:00+07:00'
      : `${effectiveFrom}T09:00:00+07:00`,
    recorded_by: options.retroactive ? 'ศิริพร เดโม' : 'กมลชนก เดโม',
    is_retroactive: options.retroactive ?? false,
    retroactive_reason: options.reason ?? null,
  };
}

const assignments: readonly PositionAssignment[] = [
  assignment('assign-01', 1, 1, '2026-01-01', null),
  assignment('assign-02', 2, 2, '2026-01-01', null),
  assignment('assign-03-old', 3, 3, '2026-01-01', '2026-06-30'),
  assignment('assign-03-current', 3, 4, '2026-07-01', '2026-07-31'),
  assignment('assign-03-future', 3, 13, '2026-08-01', null),
  assignment('assign-04', 4, 5, '2026-01-01', null),
  assignment('assign-05-old', 5, 14, '2026-01-01', '2026-04-30'),
  assignment('assign-05-retro', 5, 6, '2026-05-01', null, {
    retroactive: true,
    reason: 'บริษัทส่งหนังสือเปลี่ยนตัวล่าช้า จึงบันทึกตามวันที่มีผลจริงโดยคง Audit เดิมไว้',
  }),
  assignment('assign-06', 6, 7, '2026-01-01', null),
  assignment('assign-07', 7, 8, '2026-01-01', null),
  assignment('assign-08', 8, 9, '2026-01-01', null),
  assignment('assign-09', 9, 10, '2026-01-01', null),
  assignment('assign-10', 10, 11, '2026-01-01', null),
];

function isoAt(date: string, time: string) {
  return `${date}T${time}:00+07:00`;
}

function assignmentForDate(positionId: string, date: string) {
  const match = assignments.find(
    (item) =>
      item.position_id === positionId &&
      item.effective_from <= date &&
      (item.effective_to === null || item.effective_to >= date),
  );
  if (!match) throw new Error(`Missing demo assignment for ${positionId} on ${date}`);
  return match;
}

function createAttendance(date: string): readonly DailyAttendance[] {
  return positions.flatMap((position, index) => {
    if (date === DEMO_DATE && position.position_code === 'HK-06') return [];
    const activeAssignment = assignmentForDate(position.position_id, date);
    const substitute = date === DEMO_DATE && position.position_code === 'HK-03';
    const actualEmployeeId = substitute ? 'employee-12' : activeAssignment.employee_id;
    const checkInTime = `07:${String(35 + (index % 5) * 3).padStart(2, '0')}`;
    const checkedOut = date === HISTORICAL_DEMO_DATE;
    return [
      {
        attendance_id: `attendance-${date}-${position.position_code}`,
        work_date: date,
        position_id: position.position_id,
        contract_employee_id: activeAssignment.employee_id,
        actual_employee_id: actualEmployeeId,
        worker_type: substitute ? 'substitute' : 'regular',
        substitute_reason: substitute ? 'พนักงานตามสัญญาลาป่วย (DEMO DATA)' : null,
        check_in_photo: `demo://check-in/${date}/${actualEmployeeId}`,
        check_in_time: isoAt(date, checkInTime),
        check_out_photo: checkedOut ? `demo://check-out/${date}/${actualEmployeeId}` : null,
        check_out_time: checkedOut ? isoAt(date, '17:35') : null,
      },
    ];
  });
}

function currentStatus(positionCode: string, templateId: string): TaskStatus {
  if (positionCode === 'HK-01') return 'approved';
  if (positionCode === 'HK-02')
    return templateId === 'template-lobby' ? 'awaiting_inspection' : 'not_due';
  if (positionCode === 'HK-03')
    return templateId === 'template-trash-am'
      ? 'approved'
      : templateId === 'template-common'
        ? 'in_progress'
        : 'not_due';
  if (positionCode === 'HK-04')
    return templateId === 'template-trash-room' ? 'rejected' : 'not_due';
  if (positionCode === 'HK-05') return templateId === 'template-common' ? 'overdue' : 'not_due';
  if (positionCode === 'HK-06') return templateId === 'template-lobby' ? 'not_started' : 'not_due';
  if (positionCode === 'HK-07') return templateId === 'template-common' ? 'in_progress' : 'not_due';
  if (positionCode === 'HK-08') {
    if (templateId === 'template-trash-am' || templateId === 'template-trash-noon')
      return 'approved';
    if (templateId === 'template-trash-pm') return 'overdue';
    return 'not_due';
  }
  if (positionCode === 'HK-09')
    return templateId === 'template-trash-room' ? 'awaiting_inspection' : 'not_due';
  return 'not_due';
}

function decisionFor(status: TaskStatus, date: string, positionCode: string): TaskDecision | null {
  if (status === 'approved') {
    return {
      decision: 'approved',
      decided_at: isoAt(date, '11:30'),
      decided_by: 'กมลชนก เดโม',
      decided_by_role: 'juristic_staff',
      note: 'ตรวจหลักฐาน DEMO แล้ว',
      rejection_reasons: [],
      rejection_other_detail: null,
    };
  }
  if (status === 'rejected') {
    return {
      decision: 'rejected',
      decided_at: isoAt(date, '11:45'),
      decided_by: 'ธนา เดโม',
      decided_by_role: 'juristic_staff',
      note: null,
      rejection_reasons: ['พื้นที่ยังไม่สะอาด', 'รูป After ไม่ชัดเจน'],
      rejection_other_detail: null,
    };
  }
  if (positionCode === 'HK-09') return null;
  return null;
}

function createTasks(date: string): readonly DailyTaskInstance[] {
  return positions.flatMap((position) =>
    templates.map((template) => {
      const status =
        date === HISTORICAL_DEMO_DATE
          ? 'approved'
          : currentStatus(position.position_code, template.task_template_id);
      const submitted = ['approved', 'awaiting_inspection', 'rejected'].includes(status);
      const inspected = ['approved', 'rejected'].includes(status);
      const revisionNumber =
        position.position_code === 'HK-09' && template.task_template_id === 'template-trash-room'
          ? 3
          : status === 'rejected'
            ? 2
            : 1;
      const decision = decisionFor(status, date, position.position_code);
      return {
        task_instance_id: `task-${date}-${position.position_code}-${template.task_template_id}`,
        work_date: date,
        position_id: position.position_id,
        task_template_id: template.task_template_id,
        scheduled_start_time: template.scheduled_start_time,
        scheduled_end_time: template.scheduled_end_time,
        status,
        submitted_at: submitted ? isoAt(date, template.scheduled_end_time) : null,
        inspected_at: inspected ? (decision?.decided_at ?? null) : null,
        inspected_by: inspected ? (decision?.decided_by ?? null) : null,
        rejection_reason: status === 'rejected' ? 'พื้นที่ยังไม่สะอาด · รูป After ไม่ชัดเจน' : null,
        revision_number: revisionNumber,
        performer_note:
          status === 'not_due' || status === 'not_started'
            ? null
            : `หลักฐานงาน ${template.task_name} — DEMO DATA`,
        decision,
      } satisfies DailyTaskInstance;
    }),
  );
}

function evidenceFor(task: DailyTaskInstance): readonly EvidenceRevision[] {
  if (task.status === 'not_due' || task.status === 'not_started') return [];
  const hasAfter = !['in_progress', 'overdue'].includes(task.status);
  const currentPhotos = [
    {
      photo_id: `${task.task_instance_id}-before-r${task.revision_number}`,
      kind: 'before' as const,
      asset_key: `${task.position_id}-${task.task_template_id}-before`,
      captured_at: isoAt(task.work_date, task.scheduled_start_time),
      alt_text: 'ภาพจำลองก่อนปฏิบัติงาน ไม่มีข้อมูลบุคคลจริง',
    },
    ...(hasAfter
      ? [
          {
            photo_id: `${task.task_instance_id}-after-r${task.revision_number}`,
            kind: 'after' as const,
            asset_key: `${task.position_id}-${task.task_template_id}-after`,
            captured_at: isoAt(task.work_date, task.scheduled_end_time),
            alt_text: 'ภาพจำลองหลังปฏิบัติงาน ไม่มีข้อมูลบุคคลจริง',
          },
        ]
      : []),
  ];
  const currentOutcome =
    task.status === 'approved'
      ? ('approved' as const)
      : task.status === 'rejected'
        ? ('rejected' as const)
        : task.status === 'awaiting_inspection'
          ? ('submitted' as const)
          : ('draft' as const);
  if (task.position_id === 'position-09' && task.task_template_id === 'template-trash-room') {
    return [
      {
        revision_number: 1,
        submitted_at: isoAt(task.work_date, '10:45'),
        note: 'รอบแรก ภาพ After ไม่ชัด (DEMO)',
        photos: currentPhotos.map((photo) => ({
          ...photo,
          photo_id: `${photo.photo_id}-history-1`,
        })),
        outcome: 'rejected',
      },
      {
        revision_number: 2,
        submitted_at: isoAt(task.work_date, '11:20'),
        note: 'รอบสอง หลักฐานยังไม่ครบ (DEMO)',
        photos: currentPhotos.map((photo) => ({
          ...photo,
          photo_id: `${photo.photo_id}-history-2`,
        })),
        outcome: 'rejected',
      },
      {
        revision_number: 3,
        submitted_at: task.submitted_at,
        note: 'ส่งแก้ไขรอบสาม รอตรวจ (DEMO)',
        photos: currentPhotos,
        outcome: 'submitted',
      },
    ];
  }
  return [
    {
      revision_number: task.revision_number,
      submitted_at: task.submitted_at,
      note: task.performer_note ?? 'หลักฐานจำลอง',
      photos: currentPhotos,
      outcome: currentOutcome,
    },
  ];
}

function auditFor(task: DailyTaskInstance): readonly TaskAuditEntry[] {
  const entries: TaskAuditEntry[] = [];
  if (task.submitted_at) {
    entries.push({
      audit_id: `${task.task_instance_id}-submitted`,
      action: task.revision_number > 1 ? 'resubmitted' : 'submitted',
      actor_name: 'ผู้ปฏิบัติงาน DEMO',
      actor_role: 'housekeeper',
      recorded_at: task.submitted_at,
      detail: `ส่งหลักฐาน revision ${task.revision_number}`,
      previous_status: 'in_progress',
      current_status: 'awaiting_inspection',
    });
  }
  if (task.decision) {
    entries.push({
      audit_id: `${task.task_instance_id}-${task.decision.decision}`,
      action: task.decision.decision,
      actor_name: task.decision.decided_by,
      actor_role: task.decision.decided_by_role,
      recorded_at: task.decision.decided_at,
      detail:
        task.decision.decision === 'approved'
          ? 'อนุมัติงานจากหลักฐาน DEMO'
          : task.decision.rejection_reasons.join(' · '),
      previous_status: 'awaiting_inspection',
      current_status: task.decision.decision,
    });
  }
  if (task.position_id === 'position-09' && task.task_template_id === 'template-trash-room') {
    entries.unshift(
      {
        audit_id: `${task.task_instance_id}-reject-1`,
        action: 'rejected',
        actor_name: 'ธนา เดโม',
        actor_role: 'juristic_staff',
        recorded_at: isoAt(task.work_date, '10:55'),
        detail: 'Revision 1: รูป After ไม่ชัดเจน',
        previous_status: 'awaiting_inspection',
        current_status: 'rejected',
      },
      {
        audit_id: `${task.task_instance_id}-reject-2`,
        action: 'rejected',
        actor_name: 'ปาริชาติ เดโม',
        actor_role: 'juristic_staff',
        recorded_at: isoAt(task.work_date, '11:30'),
        detail: 'Revision 2: หลักฐานไม่ครบ',
        previous_status: 'awaiting_inspection',
        current_status: 'rejected',
      },
    );
  }
  return entries;
}

function assignmentAudit(): Readonly<Record<string, readonly TaskAuditEntry[]>> {
  const result: Record<string, readonly TaskAuditEntry[]> = {};
  for (const position of positions) {
    result[`position:${position.position_id}`] = assignments
      .filter((item) => item.position_id === position.position_id)
      .map((item) => ({
        audit_id: `audit-${item.assignment_id}`,
        action: 'assignment_recorded',
        actor_name: item.recorded_by,
        actor_role: 'juristic_staff',
        recorded_at: item.recorded_at,
        detail: `${item.is_retroactive ? 'บันทึกย้อนหลัง' : 'บันทึกการมอบหมาย'} ${item.company_document_reference}`,
        previous_status: null,
        current_status: null,
      }));
  }
  return result;
}

export function createDemoState(): DemoState {
  const tasks = [...createTasks(DEMO_DATE), ...createTasks(HISTORICAL_DEMO_DATE)];
  const evidenceRevisions: Record<string, readonly EvidenceRevision[]> = {};
  const auditHistory: Record<string, readonly TaskAuditEntry[]> = { ...assignmentAudit() };
  for (const task of tasks) {
    evidenceRevisions[task.task_instance_id] = evidenceFor(task);
    auditHistory[task.task_instance_id] = auditFor(task);
  }
  return {
    version: '0.1',
    positions,
    employees,
    assignments,
    attendance: [...createAttendance(DEMO_DATE), ...createAttendance(HISTORICAL_DEMO_DATE)],
    templates,
    tasks,
    evidence_revisions: evidenceRevisions,
    audit_history: auditHistory,
  };
}
