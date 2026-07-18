import { ErrorState } from '../../components/feedback/ErrorState';
import { LoadingIndicator } from '../../components/feedback/LoadingIndicator';
import { PageHeader } from '../../components/layout/PageHeader';
import { useDashboard } from '../../features/domain/hooks';

export function OperationsPage() {
  const dashboard = useDashboard();
  if (dashboard.isLoading) return <LoadingIndicator label="Loading Operations" />;
  if (dashboard.isError)
    return (
      <ErrorState
        error={{
          kind: 'network',
          title: 'Operations unavailable',
          message: dashboard.error.message,
        }}
      />
    );
  return (
    <div className="space-y-6">
      <PageHeader
        description="Priority, execution sequence, responsibility, authority, commitment, capability, availability, SLA, verification, and approval remain independent records."
        title="Operations"
      />
      <section className="card space-y-3">
        {dashboard.data?.operations.map((item) => (
          <article className="list-item" key={item.id}>
            <h2>
              {item.operationNumber} · {item.title}
            </h2>
            <p>{item.currentState}</p>
            <p className="text-sm text-muted">
              State changes require explicit commands; this view intentionally has no drag-and-drop
              transition.
            </p>
          </article>
        ))}
        {dashboard.data?.operations.length === 0 ? (
          <p className="text-muted">No active Operations are visible.</p>
        ) : null}
      </section>
    </div>
  );
}
