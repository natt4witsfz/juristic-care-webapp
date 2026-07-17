import { localAiMirror } from './boundary';

describe('AI boundary', () => {
  it('returns an explicitly non-authoritative local review draft', async () => {
    const result = await localAiMirror.compareContext(
      ['CASE-2026-000001'],
      'A technician observed moisture.',
    );
    expect(result.confidence).toBe(0);
    expect(result.sourceReferences).toEqual(['CASE-2026-000001']);
    expect(result.limitations.join(' ')).toMatch(
      /cannot verify evidence or change authoritative records/i,
    );
  });
});
