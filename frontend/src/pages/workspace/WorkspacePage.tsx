import { ErrorState } from '../../components/feedback/ErrorState';
import { LoadingIndicator } from '../../components/feedback/LoadingIndicator';
import { PageHeader } from '../../components/layout/PageHeader';
import { useAuth } from '../../features/auth/useAuth';
import { useDashboard } from '../../features/domain/hooks';

export function WorkspacePage() {
  const { access } = useAuth();
  const dashboard = useDashboard();
  if (dashboard.isLoading) return <LoadingIndicator label="Loading operational workspace" />;
  if (dashboard.isError)
    return (
      <ErrorState
        error={{
          kind: 'network',
          title: 'Workspace unavailable',
          message: dashboard.error.message,
        }}
      />
    );
  const data = dashboard.data;
  if (!data) return null;

  return (
    <div className="space-y-8">
      <PageHeader
        description="Current operational projections only; authoritative history remains immutable in the domain schemas."
        eyebrow="Operational workspace"
        title={`Welcome, ${access?.displayName ?? 'team member'}`}
      />
      <section aria-label="System totals" className="grid gap-4 sm:grid-cols-3">
        <Metric label="Open Cases" value={data.cases.length} />
        <Metric label="Verified Incidents" value={data.incidents.length} />
        <Metric label="Active Operations" value={data.operations.length} />
      </section>
      <div className="grid gap-6 lg:grid-cols-2">
        <Section title="Active announcements" empty="No active announcements.">
          {data.announcements.map((item) => (
            <article className="list-item" key={item.id}>
              <h3>{item.title}</h3>
              <p>{item.body}</p>
              <small>
                {item.severity}
                {item.acknowledgementRequired ? ' · acknowledgement required' : ''}
              </small>
            </article>
          ))}
        </Section>
        <Section title="Compliance deadlines" empty="No open deadlines.">
          {data.deadlines.map((item) => (
            <article className="list-item" key={item.id}>
              <h3>{item.title}</h3>
              <p>Due {new Date(item.dueAt).toLocaleString()}</p>
              <small>{item.currentState}</small>
            </article>
          ))}
        </Section>
        <Section title="Central work view" empty="No active Operations.">
          {data.operations.map((item) => (
            <article className="list-item" key={item.id}>
              <h3>
                {item.operationNumber} · {item.title}
              </h3>
              <p>{item.currentState}</p>
            </article>
          ))}
        </Section>
        <Section title="Organization chart" empty="No effective role assignments visible.">
          {data.organization.map((item) => (
            <article className="list-item" key={`${item.personId}-${item.roleCode}`}>
              <h3>{item.displayName}</h3>
              <p>{item.roleName}</p>
            </article>
          ))}
        </Section>
      </div>
    </div>
  );
}

function Metric({ label, value }: { readonly label: string; readonly value: number }) {
  return (
    <div className="card">
      <p className="text-sm text-muted">{label}</p>
      <p className="mt-2 text-3xl font-semibold">{value}</p>
    </div>
  );
}

function Section({
  children,
  empty,
  title,
}: {
  readonly children: React.ReactNode;
  readonly empty: string;
  readonly title: string;
}) {
  const items = Array.isArray(children) ? children : [children];
  return (
    <section className="card">
      <h2 className="section-title">{title}</h2>
      <div className="mt-4 space-y-3">
        {items.length > 0 ? children : <p className="text-muted">{empty}</p>}
      </div>
    </section>
  );
}
