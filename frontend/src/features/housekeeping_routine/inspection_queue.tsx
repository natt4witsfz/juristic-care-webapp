import { useMemo, useState } from 'react';

import { formatDemoDateTime } from './housekeeping_format';
import type { DailyBoardData, TaskStatus } from './housekeeping_types';
import { StatusBadge } from './status_badge';

interface InspectionQueueProps {
  readonly board: DailyBoardData;
  readonly onSelectTask: (taskId: string) => void;
}

type TimeBand = 'all' | 'morning' | 'afternoon' | 'evening';

function inTimeBand(time: string, band: TimeBand) {
  if (band === 'all') return true;
  const hour = Number(time.slice(0, 2));
  if (band === 'morning') return hour < 12;
  if (band === 'afternoon') return hour >= 12 && hour < 16;
  return hour >= 16;
}

export function InspectionQueue({ board, onSelectTask }: InspectionQueueProps) {
  const [positionId, setPositionId] = useState('all');
  const [area, setArea] = useState('all');
  const [status, setStatus] = useState<'all' | TaskStatus>('all');
  const [timeBand, setTimeBand] = useState<TimeBand>('all');
  const areas = [...new Set(board.rows.map((row) => row.position.responsibility_area))];
  const items = useMemo(
    () =>
      board.rows
        .flatMap((row) =>
          row.tasks
            .filter(
              (task) =>
                task.has_evidence &&
                ['overdue', 'awaiting_inspection', 'rejected', 'approved'].includes(task.status),
            )
            .map((task) => ({ row, task })),
        )
        .filter((item) => positionId === 'all' || item.row.position.position_id === positionId)
        .filter((item) => area === 'all' || item.row.position.responsibility_area === area)
        .filter((item) => status === 'all' || item.task.status === status)
        .filter((item) => inTimeBand(item.task.scheduled_start_time, timeBand))
        .sort((a, b) => {
          if (a.task.status === 'overdue' && b.task.status !== 'overdue') return -1;
          if (a.task.status !== 'overdue' && b.task.status === 'overdue') return 1;
          return (a.task.submitted_at ?? '').localeCompare(b.task.submitted_at ?? '');
        }),
    [area, board.rows, positionId, status, timeBand],
  );

  return (
    <section aria-labelledby="inspection-queue-title" className="space-y-5">
      <div>
        <h2 className="text-xl font-semibold" id="inspection-queue-title">
          Inspection Queue · คิวตรวจงาน
        </h2>
        <p className="mt-1 text-sm text-muted">
          เรียงงานเลยกำหนดก่อน แล้วตามด้วยงานที่รอตรวจนานที่สุด
        </p>
      </div>

      <div className="hk-filter-grid" aria-label="ตัวกรองคิวตรวจงาน">
        <label>
          <span>ตำแหน่ง</span>
          <select
            className="field"
            onChange={(event) => setPositionId(event.target.value)}
            value={positionId}
          >
            <option value="all">ทุกตำแหน่ง</option>
            {board.rows.map((row) => (
              <option key={row.position.position_id} value={row.position.position_id}>
                {row.position.position_code} · {row.position.position_name}
              </option>
            ))}
          </select>
        </label>
        <label>
          <span>พื้นที่</span>
          <select className="field" onChange={(event) => setArea(event.target.value)} value={area}>
            <option value="all">ทุกพื้นที่</option>
            {areas.map((item) => (
              <option key={item} value={item}>
                {item}
              </option>
            ))}
          </select>
        </label>
        <label>
          <span>สถานะ</span>
          <select
            className="field"
            onChange={(event) => setStatus(event.target.value as 'all' | TaskStatus)}
            value={status}
          >
            <option value="all">ทุกสถานะที่มีหลักฐาน</option>
            <option value="overdue">เลยกำหนด</option>
            <option value="awaiting_inspection">รอตรวจ</option>
            <option value="rejected">ไม่ผ่าน</option>
            <option value="approved">ผ่านแล้ว</option>
          </select>
        </label>
        <label>
          <span>ช่วงเวลา</span>
          <select
            className="field"
            onChange={(event) => setTimeBand(event.target.value as TimeBand)}
            value={timeBand}
          >
            <option value="all">ทุกช่วงเวลา</option>
            <option value="morning">เช้า ก่อน 12:00</option>
            <option value="afternoon">กลางวัน 12:00–15:59</option>
            <option value="evening">เย็น ตั้งแต่ 16:00</option>
          </select>
        </label>
      </div>

      {items.length === 0 ? (
        <div className="hk-empty-state">
          <strong>ไม่พบงานตามตัวกรอง</strong>
          <p>ลองเปลี่ยนตำแหน่ง พื้นที่ สถานะ หรือช่วงเวลา</p>
        </div>
      ) : (
        <div className="hk-queue-list">
          {items.map(({ row, task }, index) => (
            <button
              className="hk-queue-card"
              key={task.task_instance_id}
              onClick={() => onSelectTask(task.task_instance_id)}
              type="button"
            >
              <span className="hk-queue-card__order">{String(index + 1).padStart(2, '0')}</span>
              <span className="hk-queue-card__main">
                <strong>
                  {row.position.position_code} · {task.template.task_name}
                </strong>
                <small>
                  {row.position.position_name} · {task.scheduled_start_time}–
                  {task.scheduled_end_time}
                </small>
                <small>
                  ส่งเมื่อ {formatDemoDateTime(task.submitted_at)} · Revision {task.revision_number}
                </small>
              </span>
              <StatusBadge status={task.status} />
            </button>
          ))}
        </div>
      )}
    </section>
  );
}
