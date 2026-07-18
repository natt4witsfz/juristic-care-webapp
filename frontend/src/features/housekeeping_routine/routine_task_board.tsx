import { formatDemoDateTime, formatDemoTime, initials } from './housekeeping_format';
import { TASK_STATUS_META } from './housekeeping_status';
import type { DailyBoardData } from './housekeeping_types';
import { StatusBadge } from './status_badge';

interface RoutineTaskBoardProps {
  readonly board: DailyBoardData;
  readonly onSelectTask: (taskId: string) => void;
}

const summaryItems = [
  ['contract_positions', 'ตำแหน่งตามสัญญา', 'Positions'],
  ['checked_in', 'เช็กอินแล้ว', 'Checked in'],
  ['substitutes', 'พนักงานทดแทนวันนี้', 'Substitutes'],
  ['total_tasks', 'งานทั้งหมด', 'Tasks'],
  ['approved', 'ผ่านแล้ว', 'Approved'],
  ['awaiting_inspection', 'รอตรวจ', 'Awaiting'],
  ['in_progress', 'กำลังดำเนินการ', 'In progress'],
  ['rejected', 'ไม่ผ่าน', 'Rejected'],
  ['overdue', 'เลยกำหนด', 'Overdue'],
] as const;

export function RoutineTaskBoard({ board, onSelectTask }: RoutineTaskBoardProps) {
  return (
    <section aria-labelledby="daily-board-title" className="space-y-5">
      <div className="hk-summary-grid" aria-label="สรุปงานประจำวัน">
        {summaryItems.map(([key, label, labelEn]) => (
          <article className={`hk-summary hk-summary--${key}`} key={key}>
            <p>{label}</p>
            <strong>{board.summary[key]}</strong>
            <small>{labelEn}</small>
          </article>
        ))}
      </div>

      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h2 className="text-xl font-semibold" id="daily-board-title">
            Daily Routine Board
          </h2>
          <p className="mt-1 text-sm text-muted">
            Snapshot จำลอง {formatDemoDateTime(board.snapshot_time)} ·
            คลิกช่องที่มีหลักฐานเพื่อเปิดแผงตรวจ
          </p>
        </div>
        <div className="hk-legend" aria-label="คำอธิบายสถานะ">
          {Object.keys(TASK_STATUS_META).map((status) => (
            <StatusBadge compact key={status} status={status as keyof typeof TASK_STATUS_META} />
          ))}
        </div>
      </div>

      <div className="hk-board-frame" tabIndex={0} aria-label="ตารางงาน Routine เลื่อนแนวนอนได้">
        <table className="hk-board-table">
          <thead>
            <tr>
              <th className="hk-board-table__position" scope="col">
                Contract Position / ผู้ปฏิบัติงาน
              </th>
              <th scope="col">Check-in</th>
              {board.task_templates.map((template) => (
                <th key={template.task_template_id} scope="col">
                  <span>{template.task_name}</span>
                  <small>
                    {template.scheduled_start_time}–{template.scheduled_end_time}
                  </small>
                </th>
              ))}
              <th scope="col">Check-out</th>
            </tr>
          </thead>
          <tbody>
            {board.rows.map((row) => (
              <tr key={row.position.position_id}>
                <th className="hk-board-table__position" scope="row">
                  <div className="hk-position-cell">
                    <div
                      aria-label={`รูปเช็กอินจำลองของ ${row.actual_employee?.full_name ?? row.contract_employee.full_name}`}
                      className="hk-avatar"
                      role="img"
                    >
                      {initials(row.actual_employee?.full_name ?? row.contract_employee.full_name)}
                    </div>
                    <div>
                      <div className="flex flex-wrap items-center gap-2">
                        <strong>{row.position.position_code}</strong>
                        {row.attendance?.worker_type === 'substitute' ? (
                          <span className="hk-substitute-badge">พนักงานทดแทน · Substitute</span>
                        ) : null}
                      </div>
                      <p>{row.position.position_name}</p>
                      <small>ตามสัญญา: {row.contract_employee.full_name}</small>
                      <small>
                        ปฏิบัติงานจริง: {row.actual_employee?.full_name ?? 'ยังไม่เช็กอิน'}
                      </small>
                    </div>
                  </div>
                </th>
                <td>
                  {row.attendance ? (
                    <div className="hk-attendance-cell">
                      <span aria-hidden="true">●</span>
                      <strong>{formatDemoTime(row.attendance.check_in_time)}</strong>
                      <small title={row.attendance.check_in_photo}>มีรูปเช็กอิน DEMO</small>
                    </div>
                  ) : (
                    <div className="hk-attendance-cell hk-attendance-cell--missing">
                      <span aria-hidden="true">!</span>
                      <strong>ยังไม่เช็กอิน</strong>
                      <small>Not checked in</small>
                    </div>
                  )}
                </td>
                {row.tasks.map((task) => {
                  const taskContent = (
                    <>
                      <StatusBadge compact status={task.status} />
                      <small>Rev. {task.revision_number}</small>
                      {task.decision ? (
                        <small title={task.decision.decided_at}>
                          โดย {task.decision.decided_by}
                        </small>
                      ) : null}
                    </>
                  );
                  return (
                    <td key={task.task_instance_id}>
                      {task.has_evidence ? (
                        <button
                          aria-label={`${row.position.position_code} ${task.template.task_name} ${TASK_STATUS_META[task.status].label} เปิดหลักฐาน`}
                          className="hk-task-cell"
                          onClick={() => onSelectTask(task.task_instance_id)}
                          type="button"
                        >
                          {taskContent}
                        </button>
                      ) : (
                        <div className="hk-task-cell hk-task-cell--static">{taskContent}</div>
                      )}
                    </td>
                  );
                })}
                <td>
                  {row.attendance?.check_out_time ? (
                    <div className="hk-attendance-cell">
                      <span aria-hidden="true">✓</span>
                      <strong>{formatDemoTime(row.attendance.check_out_time)}</strong>
                      <small>มีรูป Check-out</small>
                    </div>
                  ) : (
                    <div className="hk-attendance-cell">
                      <span aria-hidden="true">○</span>
                      <strong>ยังไม่ Check-out</strong>
                      <small>{row.attendance ? 'รอจบรอบงาน' : 'ยังไม่มาทำงาน'}</small>
                    </div>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}
