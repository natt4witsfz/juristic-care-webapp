import type {
  ApproveTaskInput,
  DailyBoardData,
  DailyReport,
  DailyTaskInstance,
  PositionHistoryData,
  RejectTaskInput,
  ReopenTaskInput,
  ResubmitTaskInput,
  TaskInspectionDetail,
} from './housekeeping_types';

export interface HousekeepingRoutineRepository {
  getDailyBoard(date: string): Promise<DailyBoardData>;
  getTaskInspection(taskId: string): Promise<TaskInspectionDetail>;
  approveTask(input: ApproveTaskInput): Promise<DailyTaskInstance>;
  rejectTask(input: RejectTaskInput): Promise<DailyTaskInstance>;
  reopenTask(input: ReopenTaskInput): Promise<DailyTaskInstance>;
  resubmitTask(input: ResubmitTaskInput): Promise<DailyTaskInstance>;
  getPositionHistory(positionId: string, asOfDate: string): Promise<PositionHistoryData>;
  getDailyReport(date: string): Promise<DailyReport>;
  resetDemoData(): Promise<void>;
}
