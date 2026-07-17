import { ErrorState } from '../../components/feedback/ErrorState';
import { LoadingIndicator } from '../../components/feedback/LoadingIndicator';
import { PageHeader } from '../../components/layout/PageHeader';
import { useDashboard } from '../../features/domain/hooks';

export function IncidentsPage() {
  const dashboard = useDashboard();
  if (dashboard.isLoading) return <LoadingIndicator label="Loading Incidents" />;
  if (dashboard.isError)
    return (
      <ErrorState
        error={{
          kind: 'network',
          title: 'Incidents unavailable',
          message: dashboard.error.message,
        }}
      />
    );
  return (
    <div className="space-y-6">
      <PageHeader
        description="An Incident is a verified operational event. Cases remain separate and are linked by human-led Investigation."
        title="Incidents"
      />
      <section className="card space-y-3">
        {dashboard.data?.incidents.map((item) => (
          <article className="list-item" key={item.id}>
            <h2>{item.incidentNumber}</h2>
            <p>{item.currentSummary || 'No current summary.'}</p>
            <small>{item.currentState}</small>
          </article>
        ))}
        {dashboard.data?.incidents.length === 0 ? (
          <p className="text-muted">No verified Incidents are visible.</p>
        ) : null}
      </section>
    </div>
  );
}
