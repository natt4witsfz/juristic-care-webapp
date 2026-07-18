import { vi } from 'vitest';

const rpc = vi.hoisted(() => vi.fn());

vi.mock('../../lib/supabase/client', () => ({
  getSupabaseClient: () => ({ schema: () => ({ rpc }) }),
}));

import { supabaseDomainGateway } from './gateway';

describe('Case command gateway', () => {
  it('submits repeated observations as two independent Case commands', async () => {
    rpc
      .mockResolvedValueOnce({
        data: { case_id: 'case-1', case_number: 'CASE-2026-000001', report_id: 'report-1' },
        error: null,
      })
      .mockResolvedValueOnce({
        data: { case_id: 'case-2', case_number: 'CASE-2026-000002', report_id: 'report-2' },
        error: null,
      });

    const input = {
      juristicPersonId: 'tenant-1',
      channel: 'resident_form' as const,
      submittedText: 'Water is entering the bedroom wall.',
    };
    const first = await supabaseDomainGateway.createCase(input);
    const second = await supabaseDomainGateway.createCase(input);

    expect(rpc).toHaveBeenCalledTimes(2);
    expect(first.caseId).not.toBe(second.caseId);
    expect(first.reportId).not.toBe(second.reportId);
    expect(first.caseNumber).not.toBe(second.caseNumber);
  });
});
