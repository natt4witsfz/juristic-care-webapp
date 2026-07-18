import type { DailyReport, StoredReport } from './housekeeping_types';
import type { ReportStorageAdapter } from './report_storage_adapter';

export class MockReportStorageAdapter implements ReportStorageAdapter {
  async saveDailyReport(report: DailyReport): Promise<StoredReport> {
    const [year = 'YYYY', month = 'MM'] = report.work_date.split('-');
    return Promise.resolve({
      stored_report_id: `stored-${report.report_id}`,
      stored_at: new Date().toISOString(),
      path: `O83_Care/Contractor_Reports/Housekeeping/${year}/${month}/`,
      provider: 'mock',
    });
  }
}
