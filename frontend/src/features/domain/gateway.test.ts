import { vi } from 'vitest';

const rpc = vi.hoisted(() => vi.fn());
const select = vi.hoisted(() => vi.fn());
const invoke = vi.hoisted(() => vi.fn());
const upload = vi.hoisted(() => vi.fn());

vi.mock('../../lib/supabase/client', () => ({
  getSupabaseClient: () => ({
    schema: () => ({ rpc, from: () => ({ select }) }),
    storage: { from: () => ({ upload }) },
    functions: { invoke },
  }),
}));

import { supabaseDomainGateway } from './gateway';

describe('Case command gateway', () => {
  beforeEach(() => {
    rpc.mockReset();
    select.mockReset();
    invoke.mockReset();
    upload.mockReset();
  });

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

  it('forwards an operational command only through the controlled API schema', async () => {
    rpc.mockResolvedValue({ data: { state: 'completed', row_version: 4 }, error: null });
    const parameters = {
      p_juristic_person_id: 'tenant-1',
      p_operation_id: 'operation-1',
      p_expected_version: 3,
      p_to_state: 'completed',
      p_reason: 'All accepted tasks and required Evidence are complete.',
    };

    await supabaseDomainGateway.execute('transition_operation', parameters);

    expect(rpc).toHaveBeenCalledWith('transition_operation', parameters);
  });

  it('loads an RLS-filtered operational projection without direct authoritative-table access', async () => {
    select.mockResolvedValue({
      data: [{ id: 'operation-1', current_state: 'authorized' }],
      error: null,
    });

    await expect(supabaseDomainGateway.loadProjection('operation_workspace')).resolves.toEqual([
      { id: 'operation-1', current_state: 'authorized' },
    ]);
    expect(select).toHaveBeenCalledWith('*');
  });

  it('invokes a trusted server workflow without adding a browser service credential', async () => {
    invoke.mockResolvedValue({ data: { manifest_id: 'manifest-1', state: 'sealed' }, error: null });

    await expect(
      supabaseDomainGateway.invokeTrustedWorkflow('memory-transfer', {
        action: 'export',
        juristicPersonId: 'tenant-1',
      }),
    ).resolves.toEqual({ manifest_id: 'manifest-1', state: 'sealed' });
    expect(invoke).toHaveBeenCalledWith('memory-transfer', {
      body: { action: 'export', juristicPersonId: 'tenant-1' },
    });
  });

  it('rejects an incomplete Evidence request before issuing an upload intent', async () => {
    const file = new File(['evidence'], 'evidence.txt', { type: 'text/plain' });

    await expect(
      supabaseDomainGateway.uploadEvidence({
        juristicPersonId: 'tenant-1',
        targetType: 'case',
        targetId: '',
        file,
        evidenceType: 'observation',
        relevance: 'Supports the resident observation.',
        captureMethod: 'resident_upload',
        capturedAt: new Date(0).toISOString(),
      }),
    ).rejects.toThrow('Evidence target and a non-empty file are required.');
    expect(rpc).not.toHaveBeenCalled();
    expect(upload).not.toHaveBeenCalled();
    expect(invoke).not.toHaveBeenCalled();
  });
});
