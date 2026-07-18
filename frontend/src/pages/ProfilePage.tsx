import { PageHeader } from '../components/layout/PageHeader';
import { useAuth } from '../features/auth/useAuth';

export function ProfilePage() {
  const { access, user } = useAuth();
  return (
    <div className="space-y-6">
      <PageHeader
        description="Identity comes from Supabase Auth; organizational authority comes from effective O83 assignments."
        title="Your profile"
      />
      <dl className="card grid gap-4 sm:grid-cols-2">
        <div>
          <dt className="term">Name</dt>
          <dd>{access?.displayName}</dd>
        </div>
        <div>
          <dt className="term">Email</dt>
          <dd>{user?.email}</dd>
        </div>
        <div>
          <dt className="term">Roles</dt>
          <dd>{access?.roles.join(', ') || 'No effective role'}</dd>
        </div>
        <div>
          <dt className="term">Permissions</dt>
          <dd>{access?.permissions.length ?? 0} effective permissions</dd>
        </div>
      </dl>
    </div>
  );
}
