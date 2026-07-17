import { Navigate, Outlet, useLocation } from 'react-router-dom';

import { FullPageLoader } from '../../components/feedback/FullPageLoader';
import { useAuth } from './useAuth';

interface ProtectedRouteProps {
  readonly permissions?: readonly string[];
  readonly roles?: readonly string[];
}

export function ProtectedRoute({ permissions = [], roles = [] }: ProtectedRouteProps) {
  const auth = useAuth();
  const location = useLocation();
  if (auth.loading) return <FullPageLoader label="Restoring secure session" />;
  if (!auth.user) return <Navigate replace state={{ from: location.pathname }} to="/sign-in" />;
  if (!auth.access) return <Navigate replace to="/unauthorized" />;
  const rolesAllowed = roles.length === 0 || auth.hasAnyRole(roles);
  const permissionsAllowed =
    permissions.length === 0 || permissions.every((permission) => auth.hasPermission(permission));
  return rolesAllowed && permissionsAllowed ? <Outlet /> : <Navigate replace to="/unauthorized" />;
}
