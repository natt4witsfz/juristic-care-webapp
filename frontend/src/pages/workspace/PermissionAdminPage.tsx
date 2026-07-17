import { PageHeader } from '../../components/layout/PageHeader';
import { useAuth } from '../../features/auth/useAuth';

export function PermissionAdminPage() {
  const { access } = useAuth();
  return (
    <div className="space-y-6">
      <PageHeader
        description="Current effective access is resolved from database-owned roles and permission mappings. Changes require audited administrative commands."
        title="Permission administration"
      />
      <section className="card">
        <h2 className="section-title">Your effective permissions</h2>
        <ul className="mt-4 list-disc space-y-2 pl-5">
          {access?.permissions.map((permission) => (
            <li key={permission}>{permission}</li>
          ))}
        </ul>
        <p className="mt-4 text-sm text-muted">
          Invitation and permission mutation require a deployed server-side administration function
          and are not exposed directly to the browser.
        </p>
      </section>
    </div>
  );
}
