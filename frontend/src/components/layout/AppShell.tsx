import { NavLink, Outlet, useNavigate } from 'react-router-dom';

import { PageContainer } from '../common/PageContainer';
import { useAuth } from '../../features/auth/useAuth';

export function AppShell() {
  const auth = useAuth();
  const navigate = useNavigate();
  const signOut = async () => {
    await auth.signOut();
    navigate('/', { replace: true });
  };

  return (
    <div className="min-h-screen bg-surface text-ink">
      <header className="border-b border-line bg-panel">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
          <NavLink className="font-semibold tracking-tight" to="/">
            O83 Care
          </NavLink>
          <nav
            aria-label="Primary navigation"
            className="flex flex-wrap items-center justify-end gap-4 text-sm"
          >
            {auth.user ? (
              <NavLink className="link" to="/workspace">
                Workspace
              </NavLink>
            ) : null}
            {auth.user ? (
              <NavLink className="link" to="/cases">
                Cases
              </NavLink>
            ) : null}
            {auth.user ? (
              <NavLink className="link" to="/incidents">
                Incidents
              </NavLink>
            ) : null}
            {auth.user ? (
              <NavLink className="link" to="/operations">
                Operations
              </NavLink>
            ) : null}
            {auth.user ? (
              <NavLink className="link" to="/ai-advisor">
                AI mirror
              </NavLink>
            ) : null}
            {auth.hasAnyRole(['admin']) ? (
              <NavLink className="link" to="/administration/permissions">
                Permissions
              </NavLink>
            ) : null}
            <NavLink className="link" to="/system-status">
              System status
            </NavLink>
            {auth.user ? (
              <NavLink className="link" to="/profile">
                Profile
              </NavLink>
            ) : (
              <NavLink className="link" to="/sign-in">
                Sign in
              </NavLink>
            )}
            {auth.user ? (
              <button className="button-secondary" onClick={() => void signOut()} type="button">
                Sign out
              </button>
            ) : null}
          </nav>
        </div>
      </header>
      <PageContainer as="main">
        <Outlet />
      </PageContainer>
    </div>
  );
}
