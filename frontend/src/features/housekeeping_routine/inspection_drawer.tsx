import { useMemo, useState } from 'react';

import { REJECTION_REASONS } from './housekeeping_seed';
import { formatDemoDateTime, formatDemoTime, initials } from './housekeeping_format';
import type { EvidencePhoto, InspectorUser, TaskInspectionDetail } from './housekeeping_types';
import { StatusBadge } from './status_badge';

interface InspectionDrawerProps {
  readonly detail: TaskInspectionDetail | null;
  readonly isLoading: boolean;
  readonly inspector: InspectorUser;
  readonly onClose: () => void;
  readonly onApprove: (note: string | null) => Promise<void>;
  readonly onReject: (reasons: readonly string[], otherDetail: string | null) => Promise<void>;
  readonly onReopen: (reason: string) => Promise<void>;
  readonly onResubmit: () => Promise<void>;
}

type DecisionMode = 'view' | 'approve' | 'reject' | 'reopen';

function DemoPhoto({
  photo,
  onExpand,
}: {
  readonly photo: EvidencePhoto;
  readonly onExpand: () => void;
}) {
  return (
    <button
      aria-label={`ขยาย${photo.kind === 'before' ? 'ภาพก่อนทำ' : 'ภาพหลังทำ'}`}
      className={`hk-evidence-photo hk-evidence-photo--${photo.kind}`}
      onClick={onExpand}
      type="button"
    >
      <span className="hk-evidence-photo__scene" data-asset={photo.asset_key}>
        <span
          aria-hidden="true"
          className="hk-evidence-photo__shape hk-evidence-photo__shape--one"
        />
        <span
          aria-hidden="true"
          className="hk-evidence-photo__shape hk-evidence-photo__shape--two"
        />
        <span className="hk-evidence-photo__watermark">DEMO PHOTO</span>
      </span>
      <span className="hk-evidence-photo__caption">
        <strong>{photo.kind === 'before' ? 'Before · ก่อนทำ' : 'After · หลังทำ'}</strong>
        <small>{formatDemoDateTime(photo.captured_at)}</small>
      </span>
    </button>
  );
}

export function InspectionDrawer({
  detail,
  isLoading,
  inspector,
  onClose,
  onApprove,
  onReject,
  onReopen,
  onResubmit,
}: InspectionDrawerProps) {
  const [mode, setMode] = useState<DecisionMode>('view');
  const [note, setNote] = useState('');
  const [selectedReasons, setSelectedReasons] = useState<string[]>([]);
  const [otherDetail, setOtherDetail] = useState('');
  const [reopenReason, setReopenReason] = useState('');
  const [actionError, setActionError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [expandedPhoto, setExpandedPhoto] = useState<EvidencePhoto | null>(null);

  const latestRevision = detail?.evidence_revisions.at(-1) ?? null;
  const submittedOnTime = useMemo(() => {
    if (!detail?.task.submitted_at) return null;
    const dueAt = new Date(
      `${detail.task.work_date}T${detail.task.scheduled_end_time}:00+07:00`,
    ).getTime();
    return new Date(detail.task.submitted_at).getTime() <= dueAt;
  }, [detail]);

  if (!detail && !isLoading) return null;

  const runAction = async (action: () => Promise<void>) => {
    setIsSubmitting(true);
    setActionError(null);
    try {
      await action();
      setMode('view');
    } catch (error: unknown) {
      setActionError(error instanceof Error ? error.message : 'เกิดข้อผิดพลาดใน DEMO');
    } finally {
      setIsSubmitting(false);
    }
  };

  const toggleReason = (reason: string) => {
    setSelectedReasons((current) =>
      current.includes(reason) ? current.filter((item) => item !== reason) : [...current, reason],
    );
  };

  return (
    <div className="hk-drawer-backdrop" role="presentation">
      <aside aria-label="Inspection Drawer" aria-modal="true" className="hk-drawer" role="dialog">
        <header className="hk-drawer__header">
          <div>
            <p>Inspection Drawer · ตรวจหลักฐาน</p>
            <h2>
              {detail
                ? `${detail.position.position_code} · ${detail.template.task_name}`
                : 'กำลังโหลด'}
            </h2>
          </div>
          <button
            aria-label="ปิดแผงตรวจ"
            className="hk-icon-button"
            onClick={onClose}
            type="button"
          >
            ×
          </button>
        </header>

        {isLoading || !detail ? (
          <div className="hk-drawer__loading" role="status">
            กำลังโหลดหลักฐาน DEMO…
          </div>
        ) : (
          <div className="hk-drawer__body">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <StatusBadge status={detail.task.status} />
              <span className="hk-revision-badge">Revision {detail.task.revision_number}</span>
            </div>

            <section className="hk-detail-section">
              <h3>ตำแหน่งตามสัญญา</h3>
              <dl className="hk-detail-grid">
                <div>
                  <dt>รหัสตำแหน่ง</dt>
                  <dd>{detail.position.position_code}</dd>
                </div>
                <div>
                  <dt>พื้นที่รับผิดชอบ</dt>
                  <dd>{detail.position.position_name}</dd>
                </div>
                <div>
                  <dt>พนักงานตามสัญญา</dt>
                  <dd>{detail.contract_employee.full_name}</dd>
                </div>
                <div>
                  <dt>บริษัท</dt>
                  <dd>{detail.contract_employee.contractor_company}</dd>
                </div>
              </dl>
            </section>

            <section className="hk-detail-section">
              <h3>ผู้ปฏิบัติงานจริง</h3>
              {detail.attendance && detail.actual_employee ? (
                <div className="hk-worker-card">
                  <div aria-hidden="true" className="hk-avatar hk-avatar--large">
                    {initials(detail.actual_employee.full_name)}
                  </div>
                  <div>
                    <strong>{detail.actual_employee.full_name}</strong>
                    <p>
                      เช็กอิน {formatDemoTime(detail.attendance.check_in_time)} ·{' '}
                      {detail.attendance.worker_type === 'substitute' ? 'substitute' : 'regular'}
                    </p>
                    {detail.attendance.substitute_reason ? (
                      <small>เหตุผล: {detail.attendance.substitute_reason}</small>
                    ) : null}
                  </div>
                  <div className="hk-checkin-proof" title={detail.attendance.check_in_photo}>
                    <span aria-hidden="true">▣</span>
                    <small>รูปเช็กอิน DEMO</small>
                  </div>
                </div>
              ) : (
                <p className="hk-warning-box">ยังไม่มีข้อมูลเช็กอินสำหรับตำแหน่งนี้</p>
              )}
            </section>

            <section className="hk-detail-section">
              <h3>ข้อมูลงานและเวลา</h3>
              <dl className="hk-detail-grid">
                <div>
                  <dt>จุดปฏิบัติงาน</dt>
                  <dd>
                    {detail.position.building} · {detail.template.location}
                  </dd>
                </div>
                <div>
                  <dt>รอบที่กำหนด</dt>
                  <dd>
                    {detail.task.scheduled_start_time}–{detail.task.scheduled_end_time}
                  </dd>
                </div>
                <div>
                  <dt>เวลา Before</dt>
                  <dd>
                    {formatDemoDateTime(
                      latestRevision?.photos.find((photo) => photo.kind === 'before')
                        ?.captured_at ?? null,
                    )}
                  </dd>
                </div>
                <div>
                  <dt>เวลา After</dt>
                  <dd>
                    {formatDemoDateTime(
                      latestRevision?.photos.find((photo) => photo.kind === 'after')?.captured_at ??
                        null,
                    )}
                  </dd>
                </div>
                <div>
                  <dt>เวลาส่งงาน</dt>
                  <dd>{formatDemoDateTime(detail.task.submitted_at)}</dd>
                </div>
                <div>
                  <dt>ตรงเวลา</dt>
                  <dd>
                    {submittedOnTime === null
                      ? 'ยังไม่ส่ง'
                      : submittedOnTime
                        ? '✓ ตรงเวลา'
                        : '⚠ เกินเวลา'}
                  </dd>
                </div>
              </dl>
            </section>

            <section className="hk-detail-section">
              <div className="flex items-center justify-between gap-3">
                <h3>หลักฐาน Before / After</h3>
                <small>กดรูปเพื่อขยาย</small>
              </div>
              {latestRevision && latestRevision.photos.length > 0 ? (
                <div className="hk-evidence-grid">
                  {latestRevision.photos.map((photo) => (
                    <DemoPhoto
                      key={photo.photo_id}
                      onExpand={() => setExpandedPhoto(photo)}
                      photo={photo}
                    />
                  ))}
                  {latestRevision.photos.every((photo) => photo.kind !== 'after') ? (
                    <div className="hk-evidence-missing">
                      <strong>ยังไม่มีภาพ After</strong>
                      <small>งานยังไม่ถูกส่งตรวจ</small>
                    </div>
                  ) : null}
                </div>
              ) : (
                <p className="hk-warning-box">ยังไม่มีหลักฐานใน revision นี้</p>
              )}
              <p className="hk-note-box">
                <strong>หมายเหตุผู้ปฏิบัติงาน:</strong>{' '}
                {detail.task.performer_note ?? 'ไม่มีหมายเหตุ'}
              </p>
            </section>

            <section className="hk-detail-section">
              <h3>Revision History · ประวัติส่งแก้ไข</h3>
              <ol className="hk-timeline">
                {detail.evidence_revisions.map((revision) => (
                  <li key={revision.revision_number}>
                    <span aria-hidden="true" />
                    <div>
                      <strong>
                        Revision {revision.revision_number} · {revision.outcome}
                      </strong>
                      <p>{revision.note}</p>
                      <small>
                        ส่ง {formatDemoDateTime(revision.submitted_at)} · เก็บภาพ{' '}
                        {revision.photos.length} รายการ
                      </small>
                    </div>
                  </li>
                ))}
              </ol>
            </section>

            <section className="hk-detail-section">
              <h3>Audit History</h3>
              {detail.audit_history.length === 0 ? (
                <p className="text-sm text-muted">ยังไม่มี Audit entry</p>
              ) : (
                <ol className="hk-audit-list">
                  {detail.audit_history.map((entry) => (
                    <li key={entry.audit_id}>
                      <strong>{entry.action}</strong>
                      <span>{entry.detail}</span>
                      <small>
                        {entry.actor_name} · {entry.actor_role} ·{' '}
                        {formatDemoDateTime(entry.recorded_at)}
                      </small>
                    </li>
                  ))}
                </ol>
              )}
            </section>

            {detail.task.decision ? (
              <section className="hk-decision-record">
                <strong>
                  ตัดสินแล้ว:{' '}
                  {detail.task.decision.decision === 'approved' ? 'อนุมัติ' : 'ไม่อนุมัติ'}
                </strong>
                <p>
                  โดย {detail.task.decision.decided_by} · {detail.task.decision.decided_by_role} ·{' '}
                  {formatDemoDateTime(detail.task.decision.decided_at)}
                </p>
                <small>ปุ่มอนุมัติ/ไม่อนุมัติถูกปิดเพื่อป้องกันการตัดสินซ้ำ</small>
              </section>
            ) : null}

            {mode === 'approve' ? (
              <section className="hk-action-panel hk-action-panel--approve">
                <h3>ยืนยันการอนุมัติ</h3>
                <p>ผู้ตรวจ: {inspector.full_name}</p>
                <label>
                  หมายเหตุ (ไม่บังคับ)
                  <textarea
                    className="field"
                    onChange={(event) => setNote(event.target.value)}
                    rows={3}
                    value={note}
                  />
                </label>
                <div className="hk-action-row">
                  <button
                    className="button-secondary"
                    onClick={() => setMode('view')}
                    type="button"
                  >
                    ยกเลิก
                  </button>
                  <button
                    className="hk-button hk-button--approve"
                    disabled={isSubmitting}
                    onClick={() => void runAction(() => onApprove(note.trim() || null))}
                    type="button"
                  >
                    ยืนยันอนุมัติ
                  </button>
                </div>
              </section>
            ) : null}

            {mode === 'reject' ? (
              <section className="hk-action-panel hk-action-panel--reject">
                <h3>ไม่อนุมัติและส่งกลับแก้ไข</h3>
                <fieldset>
                  <legend>เลือกเหตุผลอย่างน้อยหนึ่งรายการ</legend>
                  <div className="hk-reason-grid">
                    {REJECTION_REASONS.map((reason) => (
                      <label key={reason}>
                        <input
                          checked={selectedReasons.includes(reason)}
                          onChange={() => toggleReason(reason)}
                          type="checkbox"
                        />
                        <span>{reason}</span>
                      </label>
                    ))}
                  </div>
                </fieldset>
                {selectedReasons.includes('อื่น ๆ') ? (
                  <label>
                    รายละเอียดอื่น ๆ (บังคับ)
                    <textarea
                      className="field"
                      onChange={(event) => setOtherDetail(event.target.value)}
                      required
                      rows={3}
                      value={otherDetail}
                    />
                  </label>
                ) : null}
                <div className="hk-action-row">
                  <button
                    className="button-secondary"
                    onClick={() => setMode('view')}
                    type="button"
                  >
                    ยกเลิก
                  </button>
                  <button
                    className="hk-button hk-button--reject"
                    disabled={
                      isSubmitting ||
                      selectedReasons.length === 0 ||
                      (selectedReasons.includes('อื่น ๆ') && !otherDetail.trim())
                    }
                    onClick={() =>
                      void runAction(() =>
                        onReject(selectedReasons, otherDetail.trim() ? otherDetail.trim() : null),
                      )
                    }
                    type="button"
                  >
                    ยืนยันไม่อนุมัติ
                  </button>
                </div>
              </section>
            ) : null}

            {mode === 'reopen' ? (
              <section className="hk-action-panel">
                <h3>Reopen งานที่ตัดสินแล้ว</h3>
                <p>เฉพาะ Building Manager และต้องเก็บเหตุผลใน Audit History</p>
                <label>
                  เหตุผล (บังคับ)
                  <textarea
                    className="field"
                    onChange={(event) => setReopenReason(event.target.value)}
                    required
                    rows={3}
                    value={reopenReason}
                  />
                </label>
                <div className="hk-action-row">
                  <button
                    className="button-secondary"
                    onClick={() => setMode('view')}
                    type="button"
                  >
                    ยกเลิก
                  </button>
                  <button
                    className="button-primary"
                    disabled={isSubmitting || !reopenReason.trim()}
                    onClick={() => void runAction(() => onReopen(reopenReason.trim()))}
                    type="button"
                  >
                    ยืนยัน Reopen
                  </button>
                </div>
              </section>
            ) : null}

            {actionError ? (
              <p className="error-message" role="alert">
                {actionError}
              </p>
            ) : null}
          </div>
        )}

        {detail ? (
          <footer className="hk-drawer__footer">
            {detail.task.status === 'awaiting_inspection' && !detail.task.decision ? (
              <>
                <button
                  className="hk-button hk-button--reject"
                  onClick={() => setMode('reject')}
                  type="button"
                >
                  ไม่อนุมัติ
                </button>
                <button
                  className="hk-button hk-button--approve"
                  onClick={() => setMode('approve')}
                  type="button"
                >
                  อนุมัติ
                </button>
              </>
            ) : null}
            {detail.task.status === 'rejected' ? (
              <button
                className="button-secondary"
                disabled={isSubmitting}
                onClick={() => void runAction(onResubmit)}
                type="button"
              >
                จำลองแม่บ้านส่งแก้ไข
              </button>
            ) : null}
            {detail.task.decision && inspector.role === 'building_manager' ? (
              <button className="button-primary" onClick={() => setMode('reopen')} type="button">
                Reopen (Building Manager)
              </button>
            ) : null}
            {detail.task.decision && inspector.role !== 'building_manager' ? (
              <span className="text-sm text-muted">
                เปลี่ยนเป็น Building Manager เพื่อทดสอบ Reopen
              </span>
            ) : null}
          </footer>
        ) : null}
      </aside>

      {expandedPhoto ? (
        <div className="hk-lightbox" role="dialog" aria-label="ภาพหลักฐานขยาย" aria-modal="true">
          <button aria-label="ปิดภาพขยาย" onClick={() => setExpandedPhoto(null)} type="button">
            ×
          </button>
          <div className={`hk-lightbox__photo hk-lightbox__photo--${expandedPhoto.kind}`}>
            <span>DEMO PHOTO · {expandedPhoto.kind.toUpperCase()}</span>
          </div>
          <p>
            {expandedPhoto.alt_text} · {formatDemoDateTime(expandedPhoto.captured_at)}
          </p>
        </div>
      ) : null}
    </div>
  );
}
