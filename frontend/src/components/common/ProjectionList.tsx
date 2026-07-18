import { ErrorState } from '../feedback/ErrorState';
import { LoadingIndicator } from '../feedback/LoadingIndicator';
import { useProjection } from '../../features/domain/hooks';

function display(value: unknown): string {
  if (value == null || value === '') return '—';
  if (typeof value === 'object') return JSON.stringify(value);
  return String(value);
}

export function ProjectionList({
  empty,
  fields,
  title,
  view,
}: {
  readonly empty: string;
  readonly fields: readonly { readonly key: string; readonly label: string }[];
  readonly title: string;
  readonly view: string;
}) {
  const query = useProjection(view);
  if (query.isLoading) return <LoadingIndicator label={`Loading ${title}`} />;
  if (query.isError)
    return (
      <ErrorState
        error={{ kind: 'network', title: `${title} unavailable`, message: query.error.message }}
      />
    );
  const rows = query.data ?? [];
  return (
    <section className="card" aria-label={title}>
      <h2 className="section-title">{title}</h2>
      <div className="mt-4 space-y-3">
        {rows.map((row, index) => (
          <article className="list-item" key={String(row.id ?? `${view}-${index}`)}>
            <dl className="grid gap-x-4 gap-y-2 sm:grid-cols-2">
              {fields.map((field) => (
                <div key={field.key}>
                  <dt className="text-xs font-medium uppercase tracking-wide text-muted">
                    {field.label}
                  </dt>
                  <dd className="break-words">{display(row[field.key])}</dd>
                </div>
              ))}
            </dl>
          </article>
        ))}
        {rows.length === 0 ? <p className="text-muted">{empty}</p> : null}
      </div>
    </section>
  );
}
