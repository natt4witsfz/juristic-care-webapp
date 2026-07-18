import { useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';

import { ErrorState } from '../../components/feedback/ErrorState';
import { DEMO_DATE, DEMO_INSPECTORS } from './housekeeping_seed';
import { DailyReportPreview } from './daily_report_preview';
import type { HousekeepingRoutineRepository } from './housekeeping_repository';
import { InspectionDrawer } from './inspection_drawer';
import { InspectionQueue } from './inspection_queue';
import { MockHousekeepingRoutineRepository } from './mock_housekeeping_repository';
import { MockReportStorageAdapter } from './mock_report_storage_adapter';
import { PositionHistoryDemo } from './position_history_demo';
import type { ReportStorageAdapter } from './report_storage_adapter';
import { RoutineTaskBoard } from './routine_task_board';
import './housekeeping_routine.css';

type RoutineView = 'board' | 'queue' | 'history' | 'report';

interface HousekeepingRoutinePageProps {
  readonly repository?: HousekeepingRoutineRepository;
  readonly reportStorageAdapter?: ReportStorageAdapter;
}

const defaultRepository = new MockHousekeepingRoutineRepository();
const defaultReportStorageAdapter = new MockReportStorageAdapter();

const tabs: readonly {
  readonly id: RoutineView;
  readonly label: string;
  readonly labelEn: string;
}[] = [
  { id: 'board', label: 'บอร์ดประจำวัน', labelEn: 'Daily Board' },
  { id: 'queue', label: 'คิวตรวจงาน', labelEn: 'Inspection Queue' },
  { id: 'history', label: 'ประวัติตำแหน่ง', labelEn: 'Position History' },
  { id: 'report', label: 'รายงาน 20:00', labelEn: 'Report Preview' },
];

export function HousekeepingRoutinePage({
  repository = defaultRepository,
  reportStorageAdapter = defaultReportStorageAdapter,
}: HousekeepingRoutinePageProps) {
  const queryClient = useQueryClient();
  const [view, setView] = useState<RoutineView>('board');
  const [date, setDate] = useState(DEMO_DATE);
  const [selectedTaskId, setSelectedTaskId] = useState<string | null>(null);
  const [inspectorId, setInspectorId] = useState(DEMO_INSPECTORS[0]?.inspector_id ?? '');
  const [historyPositionId, setHistoryPositionId] = useState('position-03');
  const [historyDate, setHistoryDate] = useState(DEMO_DATE);
  const [showResetConfirmation, setShowResetConfirmation] = useState(false);
  const [resetMessage, setResetMessage] = useState<string | null>(null);

  const inspector =
    DEMO_INSPECTORS.find((item) => item.inspector_id === inspectorId) ?? DEMO_INSPECTORS[0];
  if (!inspector) throw new Error('Missing mock inspector');

  const boardQuery = useQuery({
    queryKey: ['housekeeping-routine', 'demo-tenant', 'board', date],
    queryFn: () => repository.getDailyBoard(date),
  });
  const inspectionQuery = useQuery({
    queryKey: ['housekeeping-routine', 'demo-tenant', 'inspection', selectedTaskId],
    queryFn: () => repository.getTaskInspection(selectedTaskId ?? ''),
    enabled: selectedTaskId !== null,
  });
  const historyQuery = useQuery({
    queryKey: [
      'housekeeping-routine',
      'demo-tenant',
      'position-history',
      historyPositionId,
      historyDate,
    ],
    queryFn: () => repository.getPositionHistory(historyPositionId, historyDate),
    enabled: view === 'history',
  });
  const reportQuery = useQuery({
    queryKey: ['housekeeping-routine', 'demo-tenant', 'report', date],
    queryFn: () => repository.getDailyReport(date),
    enabled: view === 'report',
  });

  const refreshOwnedQueries = async () => {
    await queryClient.invalidateQueries({ queryKey: ['housekeeping-routine', 'demo-tenant'] });
  };

  const handleApprove = async (note: string | null) => {
    if (!selectedTaskId) return;
    await repository.approveTask({ task_id: selectedTaskId, inspector, note });
    await refreshOwnedQueries();
  };

  const handleReject = async (reasons: readonly string[], otherDetail: string | null) => {
    if (!selectedTaskId) return;
    await repository.rejectTask({
      task_id: selectedTaskId,
      inspector,
      reasons,
      other_detail: otherDetail,
    });
    await refreshOwnedQueries();
  };

  const handleReopen = async (reason: string) => {
    if (!selectedTaskId) return;
    await repository.reopenTask({ task_id: selectedTaskId, inspector, reason });
    await refreshOwnedQueries();
  };

  const handleResubmit = async () => {
    if (!selectedTaskId) return;
    await repository.resubmitTask({
      task_id: selectedTaskId,
      actor_name: 'ผู้ปฏิบัติงาน DEMO',
      move_to: 'awaiting_inspection',
    });
    await refreshOwnedQueries();
  };

  const resetDemoData = async () => {
    await repository.resetDemoData();
    setSelectedTaskId(null);
    setDate(DEMO_DATE);
    setHistoryDate(DEMO_DATE);
    setShowResetConfirmation(false);
    setResetMessage('คืนข้อมูลจำลองเป็นค่าเริ่มต้นแล้ว');
    await refreshOwnedQueries();
  };

  return (
    <div className="hk-routine-page">
      <section className="hk-page-hero">
        <div>
          <div className="flex flex-wrap items-center gap-2">
            <span className="hk-prototype-badge">PROTOTYPE · MOCK DATA ONLY</span>
            <span className="hk-isolation-badge">แยกจาก Production</span>
          </div>
          <h1>Housekeeping Routine Control</h1>
          <p>
            Functional Mockup สำหรับติดตาม ตรวจ และอนุมัติงาน Routine ของบริษัทแม่บ้าน
            โดยไม่มีการเชื่อมฐานข้อมูล Production หรือ Google Drive
          </p>
        </div>
        <div className="hk-prototype-note">
          <span aria-hidden="true">i</span>
          <p>DEMO DATA ทั้งหมด · สถานะที่เปลี่ยนจะบันทึกเฉพาะ localStorage ของอุปกรณ์นี้</p>
        </div>
      </section>

      <section className="hk-control-bar" aria-label="ตัวควบคุม Mockup">
        <label>
          <span>วันที่ทำงาน / Work date</span>
          <select
            className="field"
            onChange={(event) => {
              setDate(event.target.value);
              setSelectedTaskId(null);
              setResetMessage(null);
            }}
            value={date}
          >
            <option value="2026-07-18">18 ก.ค. 2026 · DEMO วันนี้</option>
            <option value="2026-06-15">15 มิ.ย. 2026 · ดูย้อนหลัง</option>
          </select>
        </label>
        <label>
          <span>ผู้ตรวจปัจจุบัน / Current inspector</span>
          <select
            className="field"
            onChange={(event) => setInspectorId(event.target.value)}
            value={inspectorId}
          >
            {DEMO_INSPECTORS.map((item) => (
              <option key={item.inspector_id} value={item.inspector_id}>
                {item.full_name} · {item.role_label}
              </option>
            ))}
          </select>
        </label>
        <div className="hk-permission-summary">
          <small>Permission</small>
          <strong>inspect_contractor_work</strong>
          <span>{inspector.role_label}</span>
        </div>
        <button
          className="button-secondary"
          onClick={() => setShowResetConfirmation(true)}
          type="button"
        >
          Reset Demo Data
        </button>
      </section>

      {showResetConfirmation ? (
        <section
          className="hk-reset-confirmation"
          role="alertdialog"
          aria-label="ยืนยัน Reset Demo Data"
        >
          <div>
            <strong>คืนสถานะ DEMO ทั้งหมดหรือไม่?</strong>
            <p>การอนุมัติ/ไม่อนุมัติที่ทดลองไว้ใน localStorage จะถูกแทนด้วย seed เริ่มต้น</p>
          </div>
          <div className="hk-action-row">
            <button
              className="button-secondary"
              onClick={() => setShowResetConfirmation(false)}
              type="button"
            >
              ยกเลิก
            </button>
            <button className="button-primary" onClick={() => void resetDemoData()} type="button">
              ยืนยัน Reset
            </button>
          </div>
        </section>
      ) : null}
      {resetMessage ? (
        <p className="notice" role="status">
          {resetMessage}
        </p>
      ) : null}

      <nav aria-label="Housekeeping routine views" className="hk-tabs">
        {tabs.map((tab) => (
          <button
            aria-current={view === tab.id ? 'page' : undefined}
            className={view === tab.id ? 'hk-tab hk-tab--active' : 'hk-tab'}
            key={tab.id}
            onClick={() => setView(tab.id)}
            type="button"
          >
            <span>{tab.label}</span>
            <small>{tab.labelEn}</small>
          </button>
        ))}
      </nav>

      {boardQuery.isLoading ? (
        <div className="hk-empty-state" role="status">
          กำลังโหลด Daily Board จาก MockHousekeepingRoutineRepository…
        </div>
      ) : null}

      {boardQuery.isError ? (
        <ErrorState
          action={() => void boardQuery.refetch()}
          actionLabel="ลองโหลดอีกครั้ง"
          error={{
            kind: 'network',
            title: 'โหลด Housekeeping Mockup ไม่สำเร็จ',
            message: boardQuery.error.message,
          }}
        />
      ) : null}

      {boardQuery.data ? (
        <div className="hk-view-panel">
          {view === 'board' ? (
            <RoutineTaskBoard board={boardQuery.data} onSelectTask={setSelectedTaskId} />
          ) : null}
          {view === 'queue' ? (
            <InspectionQueue board={boardQuery.data} onSelectTask={setSelectedTaskId} />
          ) : null}
          {view === 'history' ? (
            <PositionHistoryDemo
              asOfDate={historyDate}
              history={historyQuery.data ?? null}
              isLoading={historyQuery.isLoading}
              onDateChange={setHistoryDate}
              onPositionChange={setHistoryPositionId}
              positions={boardQuery.data.rows.map((row) => row.position)}
              selectedPositionId={historyPositionId}
            />
          ) : null}
          {view === 'report' ? (
            <DailyReportPreview
              isLoading={reportQuery.isLoading}
              onSelectTask={setSelectedTaskId}
              report={reportQuery.data ?? null}
              storageAdapter={reportStorageAdapter}
            />
          ) : null}
        </div>
      ) : null}

      <InspectionDrawer
        detail={inspectionQuery.data ?? null}
        inspector={inspector}
        isLoading={inspectionQuery.isLoading}
        key={selectedTaskId ?? 'closed'}
        onApprove={handleApprove}
        onClose={() => setSelectedTaskId(null)}
        onReject={handleReject}
        onReopen={handleReopen}
        onResubmit={handleResubmit}
      />
    </div>
  );
}
