import { getEnvironment } from '../config/environment';
import { PageHeader } from '../components/layout/PageHeader';

export function SystemStatusPage() {
  const environment = getEnvironment();
  const isDevelopment = environment.appEnvironment === 'development';

  return (
    <div className="space-y-8">
      <PageHeader
        description="This page reports public application readiness only. It does not test private services or reveal credentials."
        eyebrow="Diagnostics"
        title="System status"
      />
      <dl className="grid gap-4 sm:grid-cols-2" aria-label="Public system status">
        <StatusItem label="Application" value="Available" />
        <StatusItem label="Configuration" value="Valid" />
        <StatusItem label="Environment" value={environment.appEnvironment} />
        <StatusItem label="Version" value={environment.appVersion} />
      </dl>
      {isDevelopment ? (
        <aside className="rounded-xl border border-line bg-panel p-5 text-sm text-muted">
          Development diagnostics: the Supabase URL and browser-safe key are configured. Their
          values are intentionally hidden.
        </aside>
      ) : null}
    </div>
  );
}

interface StatusItemProps {
  readonly label: string;
  readonly value: string;
}

function StatusItem({ label, value }: StatusItemProps) {
  return (
    <div className="rounded-xl border border-line bg-panel p-5">
      <dt className="text-sm text-muted">{label}</dt>
      <dd className="mt-1 font-semibold capitalize">{value}</dd>
    </div>
  );
}
