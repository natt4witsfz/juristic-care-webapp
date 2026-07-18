import { useState } from 'react';

import { formatDemoDate, formatDemoDateTime, initials } from './housekeeping_format';
import type { ContractPosition, PositionHistoryData } from './housekeeping_types';

interface PositionHistoryDemoProps {
  readonly positions: readonly ContractPosition[];
  readonly history: PositionHistoryData | null;
  readonly isLoading: boolean;
  readonly selectedPositionId: string;
  readonly asOfDate: string;
  readonly onPositionChange: (positionId: string) => void;
  readonly onDateChange: (date: string) => void;
}

export function PositionHistoryDemo({
  positions,
  history,
  isLoading,
  selectedPositionId,
  asOfDate,
  onPositionChange,
  onDateChange,
}: PositionHistoryDemoProps) {
  const [documentMessage, setDocumentMessage] = useState<string | null>(null);

  return (
    <section aria-labelledby="position-history-title" className="space-y-5">
      <div>
        <h2 className="text-xl font-semibold" id="position-history-title">
          Employee & Position History Demo
        </h2>
        <p className="mt-1 text-sm text-muted">
          แยกตำแหน่งตามสัญญาออกจากบุคคล และคำนวณผู้มีผลตามวันที่เลือกโดยไม่แก้ข้อมูลย้อนหลัง
        </p>
      </div>

      <div className="hk-history-toolbar">
        <label>
          <span>Contract Position</span>
          <select
            className="field"
            onChange={(event) => onPositionChange(event.target.value)}
            value={selectedPositionId}
          >
            {positions.map((position) => (
              <option key={position.position_id} value={position.position_id}>
                {position.position_code} · {position.position_name}
              </option>
            ))}
          </select>
        </label>
        <label>
          <span>ดูข้อมูล ณ วันที่ / As of</span>
          <select
            className="field"
            onChange={(event) => onDateChange(event.target.value)}
            value={asOfDate}
          >
            <option value="2026-06-15">15 มิ.ย. 2026 · ก่อนเปลี่ยน HK-03</option>
            <option value="2026-07-18">18 ก.ค. 2026 · ปัจจุบัน DEMO</option>
            <option value="2026-08-15">15 ส.ค. 2026 · เปลี่ยนล่วงหน้าแล้ว</option>
          </select>
        </label>
      </div>

      <div className="hk-history-callouts">
        <article>
          <span aria-hidden="true">↔</span>
          <div>
            <strong>ตัวอย่าง Effective Date</strong>
            <p>
              HK-03 เปลี่ยนจากพนักงาน A เป็น B วันที่ 1 ก.ค. และมีพนักงาน C กำหนดล่วงหน้า 1 ส.ค.
            </p>
          </div>
        </article>
        <article className="hk-history-callouts__retroactive">
          <span aria-hidden="true">⚠</span>
          <div>
            <strong>ตัวอย่างบันทึกย้อนหลัง</strong>
            <p>เลือก HK-05 เพื่อดู assignment ที่บันทึก 18 พ.ค. แต่มีผลจริงตั้งแต่ 1 พ.ค.</p>
          </div>
        </article>
      </div>

      {isLoading || !history ? (
        <div className="hk-empty-state" role="status">
          กำลังคำนวณประวัติตาม Effective Date…
        </div>
      ) : (
        <>
          <article className="hk-current-assignment">
            <div aria-hidden="true" className="hk-avatar hk-avatar--large">
              {initials(history.current_employee.full_name)}
            </div>
            <div>
              <small>ผู้มีผล ณ {formatDemoDate(history.as_of_date)}</small>
              <h3>{history.current_employee.full_name}</h3>
              <p>
                {history.position.position_code} · {history.position.position_name}
              </p>
            </div>
            <span className="hk-effective-badge">Effective assignment</span>
          </article>

          <div className="hk-history-layout">
            <section className="hk-detail-section">
              <h3>Assignment Timeline</h3>
              <ol className="hk-assignment-list">
                {history.assignments.map((assignment) => {
                  const future = assignment.effective_from > history.as_of_date;
                  const ended =
                    assignment.effective_to !== null &&
                    assignment.effective_to < history.as_of_date;
                  return (
                    <li key={assignment.assignment_id}>
                      <div className="flex flex-wrap items-center gap-2">
                        <strong>{assignment.employee.full_name}</strong>
                        {assignment.assignment_id === history.current_assignment.assignment_id ? (
                          <span className="hk-effective-badge">มีผล ณ วันที่เลือก</span>
                        ) : null}
                        {future ? <span className="hk-future-badge">กำหนดล่วงหน้า</span> : null}
                        {ended ? <span className="hk-ended-badge">สิ้นสุดแล้ว</span> : null}
                        {assignment.is_retroactive ? (
                          <span className="hk-retroactive-badge">⚠ บันทึกย้อนหลัง</span>
                        ) : null}
                      </div>
                      <p>
                        {assignment.effective_from} → {assignment.effective_to ?? 'ต่อเนื่อง'}
                      </p>
                      <small>
                        เอกสาร {assignment.company_document_reference} ลงวันที่{' '}
                        {assignment.company_document_date}
                      </small>
                      {assignment.retroactive_reason ? (
                        <p className="hk-warning-box">เหตุผล: {assignment.retroactive_reason}</p>
                      ) : null}
                      <button
                        className="button-secondary"
                        onClick={() =>
                          setDocumentMessage(
                            `เปิด metadata จำลอง ${assignment.company_document_reference} แล้ว (ไม่มีการอัปโหลดจริง)`,
                          )
                        }
                        type="button"
                      >
                        ดูหนังสือบริษัท (Mock)
                      </button>
                    </li>
                  );
                })}
              </ol>
              {documentMessage ? (
                <p className="notice" role="status">
                  {documentMessage}
                </p>
              ) : null}
            </section>

            <section className="hk-detail-section">
              <h3>Audit History</h3>
              <ol className="hk-audit-list">
                {history.audit_history.map((entry) => (
                  <li key={entry.audit_id}>
                    <strong>{entry.action}</strong>
                    <span>{entry.detail}</span>
                    <small>
                      {entry.actor_name} · {formatDemoDateTime(entry.recorded_at)}
                    </small>
                  </li>
                ))}
              </ol>
              <p className="hk-note-box">
                Audit entry เดิมคงอยู่เสมอ การบันทึกย้อนหลังเพิ่มเหตุผลและเวลา recorded_at
                โดยไม่ลบประวัติ
              </p>
            </section>
          </div>
        </>
      )}
    </section>
  );
}
