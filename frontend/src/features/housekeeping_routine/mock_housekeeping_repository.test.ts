import { DEMO_DATE, DEMO_INSPECTORS, HISTORICAL_DEMO_DATE } from './housekeeping_seed';
import { MockHousekeepingRoutineRepository } from './mock_housekeeping_repository';
import type { DailyBoardData, InspectorUser, TaskStatus } from './housekeeping_types';

class MemoryStorage implements Storage {
  private readonly values = new Map<string, string>();

  get length() {
    return this.values.size;
  }

  clear() {
    this.values.clear();
  }

  getItem(key: string) {
    return this.values.get(key) ?? null;
  }

  key(index: number) {
    return [...this.values.keys()][index] ?? null;
  }

  removeItem(key: string) {
    this.values.delete(key);
  }

  setItem(key: string, value: string) {
    this.values.set(key, value);
  }
}

function inspector(role: InspectorUser['role'] = 'juristic_staff') {
  const match = DEMO_INSPECTORS.find((item) => item.role === role);
  if (!match) throw new Error(`Missing ${role} demo inspector`);
  return match;
}

function taskId(board: DailyBoardData, positionCode: string, status: TaskStatus) {
  const row = board.rows.find((item) => item.position.position_code === positionCode);
  const task = row?.tasks.find((item) => item.status === status);
  if (!task) throw new Error(`Missing ${positionCode} ${status} task`);
  return task.task_instance_id;
}

describe('MockHousekeepingRoutineRepository', () => {
  it('transitions awaiting_inspection to approved and prevents duplicate approval', async () => {
    const repository = new MockHousekeepingRoutineRepository(new MemoryStorage());
    const board = await repository.getDailyBoard(DEMO_DATE);
    const id = taskId(board, 'HK-02', 'awaiting_inspection');

    const approved = await repository.approveTask({
      task_id: id,
      inspector: inspector(),
      note: 'หลักฐานครบถ้วน',
    });

    expect(approved.status).toBe('approved');
    expect(approved.decision?.decided_by).toBe(inspector().full_name);
    await expect(
      repository.approveTask({ task_id: id, inspector: inspector(), note: null }),
    ).rejects.toThrow(/ถูกตัดสินแล้ว/);
  });

  it('validates rejection reasons and moves rejected work back to revision flow', async () => {
    const repository = new MockHousekeepingRoutineRepository(new MemoryStorage());
    const board = await repository.getDailyBoard(DEMO_DATE);
    const id = taskId(board, 'HK-02', 'awaiting_inspection');

    await expect(
      repository.rejectTask({
        task_id: id,
        inspector: inspector(),
        reasons: [],
        other_detail: null,
      }),
    ).rejects.toThrow(/อย่างน้อยหนึ่ง/);
    await expect(
      repository.rejectTask({
        task_id: id,
        inspector: inspector(),
        reasons: ['อื่น ๆ'],
        other_detail: '  ',
      }),
    ).rejects.toThrow(/ระบุรายละเอียด/);

    const rejected = await repository.rejectTask({
      task_id: id,
      inspector: inspector(),
      reasons: ['พื้นที่ยังไม่สะอาด'],
      other_detail: null,
    });
    expect(rejected.status).toBe('rejected');
    expect(rejected.revision_number).toBe(2);

    const inProgress = await repository.resubmitTask({
      task_id: id,
      actor_name: 'ผู้ปฏิบัติงาน DEMO',
      move_to: 'in_progress',
    });
    expect(inProgress.status).toBe('in_progress');

    const evidence = await repository.getTaskInspection(id);
    expect(evidence.evidence_revisions).toHaveLength(2);
    expect(evidence.evidence_revisions[0]?.outcome).toBe('rejected');
  });

  it('allows only a Building Manager to reopen a decided task with a reason', async () => {
    const repository = new MockHousekeepingRoutineRepository(new MemoryStorage());
    const board = await repository.getDailyBoard(DEMO_DATE);
    const id = taskId(board, 'HK-01', 'approved');

    await expect(
      repository.reopenTask({ task_id: id, inspector: inspector(), reason: 'ทดสอบ' }),
    ).rejects.toThrow(/Building Manager/);
    await expect(
      repository.reopenTask({ task_id: id, inspector: inspector('building_manager'), reason: '' }),
    ).rejects.toThrow(/ระบุเหตุผล/);

    const reopened = await repository.reopenTask({
      task_id: id,
      inspector: inspector('building_manager'),
      reason: 'ตรวจซ้ำตามคำขอผู้จัดการอาคาร',
    });
    expect(reopened.status).toBe('awaiting_inspection');
    const detail = await repository.getTaskInspection(id);
    expect(detail.audit_history.at(-1)?.action).toBe('reopened');
  });

  it('resolves effective-dated HK-03 assignments without changing history', async () => {
    const repository = new MockHousekeepingRoutineRepository(new MemoryStorage());

    const oldAssignment = await repository.getPositionHistory('position-03', HISTORICAL_DEMO_DATE);
    const newAssignment = await repository.getPositionHistory('position-03', DEMO_DATE);
    const futureAssignment = await repository.getPositionHistory('position-03', '2026-08-15');

    expect(oldAssignment.current_employee.employee_code).toBe('DEMO-HK-003A');
    expect(newAssignment.current_employee.employee_code).toBe('DEMO-HK-003B');
    expect(futureAssignment.current_employee.employee_code).toBe('DEMO-HK-003C');
    expect(newAssignment.assignments).toHaveLength(3);
    expect(newAssignment.audit_history).toHaveLength(3);
  });

  it('preserves retroactive assignment metadata and audit history', async () => {
    const repository = new MockHousekeepingRoutineRepository(new MemoryStorage());
    const history = await repository.getPositionHistory('position-05', DEMO_DATE);
    const retroactive = history.assignments.find((item) => item.is_retroactive);

    expect(retroactive?.retroactive_reason).toMatch(/หนังสือ/);
    expect(history.audit_history).toHaveLength(history.assignments.length);
    expect(history.audit_history.some((entry) => entry.detail.includes('บันทึกย้อนหลัง'))).toBe(
      true,
    );
  });

  it('resets persisted decisions back to the central demo seed', async () => {
    const storage = new MemoryStorage();
    const repository = new MockHousekeepingRoutineRepository(storage);
    const initialBoard = await repository.getDailyBoard(DEMO_DATE);
    const id = taskId(initialBoard, 'HK-02', 'awaiting_inspection');
    await repository.approveTask({ task_id: id, inspector: inspector(), note: null });

    await repository.resetDemoData();
    const resetBoard = await repository.getDailyBoard(DEMO_DATE);
    expect(taskId(resetBoard, 'HK-02', 'awaiting_inspection')).toBe(id);
  });
});
