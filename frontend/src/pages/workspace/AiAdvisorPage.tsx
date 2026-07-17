import { useState } from 'react';

import { PageHeader } from '../../components/layout/PageHeader';
import { localAiMirror, type AiRecommendationDraft } from '../../features/ai/boundary';

export function AiAdvisorPage() {
  const [context, setContext] = useState('');
  const [draft, setDraft] = useState<AiRecommendationDraft | null>(null);
  return (
    <div className="space-y-6">
      <PageHeader
        description="The AI boundary may compare and recommend. It cannot approve, verify, punish, close work, or modify authoritative records."
        title="AI organizational mirror"
      />
      <section className="card space-y-4">
        <label className="field-label" htmlFor="ai-context">
          Context for local boundary check
        </label>
        <textarea
          className="field min-h-28"
          id="ai-context"
          onChange={(e) => setContext(e.target.value)}
          value={context}
        />
        <button
          className="button-primary"
          onClick={() => void localAiMirror.compareContext([], context).then(setDraft)}
          type="button"
        >
          Prepare review draft
        </button>
        {draft ? (
          <div className="notice">
            <p>{draft.recommendation}</p>
            <p>Confidence: {draft.confidence}</p>
            <p>Limitations: {draft.limitations.join(' ')}</p>
          </div>
        ) : null}
      </section>
    </div>
  );
}
