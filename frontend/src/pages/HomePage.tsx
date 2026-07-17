import { PageHeader } from '../components/layout/PageHeader';

export function HomePage() {
  return (
    <div className="space-y-10">
      <PageHeader
        description="A condominium operations and organizational-memory system that keeps reports separate, connects verified events through investigation, and preserves how understanding changes over time."
        eyebrow="O83 Care by Frostberg"
        title="Clear operational care for people living together."
      />
      <div className="grid gap-5 md:grid-cols-3">
        <article className="card">
          <h2 className="section-title">Report clearly</h2>
          <p className="mt-2 text-muted">
            Every report becomes its own traceable Case. Similar reports are never silently merged.
          </p>
        </article>
        <article className="card">
          <h2 className="section-title">Investigate responsibly</h2>
          <p className="mt-2 text-muted">
            People evaluate evidence before Cases are associated with a verified Incident.
          </p>
        </article>
        <article className="card">
          <h2 className="section-title">Remember honestly</h2>
          <p className="mt-2 text-muted">
            New evidence revises current understanding without erasing earlier observations or
            decisions.
          </p>
        </article>
      </div>
      <p className="notice">
        Human safety comes first. During an emergency, act within real-world authority and record
        actions as soon as reasonably possible after stabilization.
      </p>
    </div>
  );
}
