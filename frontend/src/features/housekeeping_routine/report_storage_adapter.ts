import type { DailyReport, StoredReport } from './housekeeping_types';

export interface ReportStorageAdapter {
  saveDailyReport(report: DailyReport): Promise<StoredReport>;
}
