import { useState } from 'react';

import { formatDemoDate, formatDemoDateTime } from './housekeeping_format';
import type { DailyReport, StoredReport } from './housekeeping_types';
import type { ReportStorageAdapter } from './report_storage_adapter';
import { StatusBadge } from './status_badge';

interface DailyReportPreviewProps {
  readonly report: DailyReport | null;
  readonly isLoading: boolean;
  readonly storageAdapter: ReportStorageAdapter;
  readonly onSelectTask: (taskId: string) => void;
}

export function DailyReportPreview({
  report,
  isLoading,
  storageAdapter,
  onSelectTask,
}: DailyReportPreviewProps) {
  const [storedReport, setStoredReport] = useState<StoredReport | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);

  const saveReport = async () => {
    if (!report) return;
    setIsSaving(true);
    setSaveError(null);
    try {
      setStoredReport(await storageAdapter.saveDailyReport(report));
    } catch (error: unknown) {
      setSaveError(error instanceof Error ? error.message : 'จัดเก็บรายงานจำลองไม่สำเร็จ');
    } finally {
      setIsSaving(false);
    }
  };

  if (isLoading || !report) {
    return (
      <div className="hk-empty-state" role="status">
        กำลังสร้าง Daily Report Preview จาก DEMO DATA…
      </div>
    );
  }

  const metrics = [
    ['ตำแหน่งตามสัญญา', report.contract_positions],
    ['คนมาทำงาน', report.workers_present],
    ['งานทั้งหมด', report.total_tasks],
    ['งานอนุมัติ', report.approved_tasks],
    ['งานรอตรวจ', report.awaiting_inspection_tasks],
    ['งานไม่ผ่าน', report.rejected_tasks],
    ['งานยังไม่ได้ทำ', report.not_started_tasks],
    ['งานเลยกำหนด', report.overdue_tasks],
  ] as const;

  return (
    <section aria-labelledby="daily-report-title" className="space-y-5">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <p className="text-sm font-semibold text-brand-strong">20:00 Snapshot Preview</p>
          <h2 className="mt-1 text-xl font-semibold" id="daily-report-title">
            รายงานประจำวัน · {formatDemoDate(report.work_date)}
          </h2>
          <p className="mt-1 text-sm text-muted">
            Snapshot time: {formatDemoDateTime(report.snapshot_time)} · Mock only
          </p>
        </div>
        <button
          className="button-primary"
          disabled={isSaving}
          onClick={() => void saveReport()}
          type="button"
        >
          {isSaving ? 'กำลังจัดเก็บ…' : 'จัดเก็บรายงาน (Mock)'}
        </button>
      </div>

      {storedReport ? (
        <div className="hk-storage-success" role="status">
          <span aria-hidden="true">✓</span>
          <div>
            <strong>จัดเก็บรายงานจำลองสำเร็จ</strong>
            <p>{storedReport.path}</p>
            <small>
              ไม่มีการเรียก Google Drive API · {formatDemoDateTime(storedReport.stored_at)}
            </small>
          </div>
        </div>
      ) : null}
      {saveError ? (
        <p className="error-message" role="alert">
          {saveError}
        </p>
      ) : null}

      <div className="hk-report-metrics">
        {metrics.map(([label, value]) => (
          <article key={label}>
            <span>{label}</span>
            <strong>{value}</strong>
          </article>
        ))}
      </div>

      <div className="hk-report-layout">
        <section className="hk-detail-section">
          <h3>พนักงานทดแทนวันนี้</h3>
          {report.substitutes.length === 0 ? (
            <p className="text-sm text-muted">ไม่มีพนักงานทดแทน</p>
          ) : (
            report.substitutes.map((item) => (
              <article className="hk-substitute-report" key={item.position_code}>
                <strong>{item.position_code}</strong>
                <p>ตามสัญญา: {item.contract_employee_name}</p>
                <p>ปฏิบัติงานจริง: {item.actual_employee_name}</p>
                <small>เหตุผล: {item.reason}</small>
              </article>
            ))
          )}
        </section>

        <section className="hk-detail-section">
          <h3>ข้อบกพร่องที่ยังไม่แก้ไข</h3>
          {report.unresolved_defects.length === 0 ? (
            <p className="text-sm text-muted">ไม่มีข้อบกพร่องค้าง</p>
          ) : (
            <div className="hk-defect-list">
              {report.unresolved_defects.map((defect) => (
                <button
                  key={defect.task_id}
                  onClick={() => onSelectTask(defect.task_id)}
                  type="button"
                >
                  <span>
                    <strong>
                      {defect.position_code} · {defect.task_name}
                    </strong>
                    <small>{defect.reasons.join(' · ')}</small>
                    <small>ผู้ตรวจ: {defect.inspector_name ?? 'ยังไม่มีผู้ตรวจ'}</small>
                  </span>
                  <StatusBadge compact status={defect.status} />
                </button>
              ))}
            </div>
          )}
        </section>
      </div>

      <p className="hk-note-box">
        ReportStorageAdapter พร้อมเปลี่ยนไปใช้ Google Drive adapter ในอนาคต โดยหน้า Preview
        นี้ไม่ต้องเขียนใหม่
      </p>
    </section>
  );
}
