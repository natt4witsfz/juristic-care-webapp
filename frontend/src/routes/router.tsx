import { createBrowserRouter, createMemoryRouter, type RouteObject } from 'react-router-dom';

import { RouteErrorPage } from '../components/feedback/RouteErrorPage';
import { FullPageLoader } from '../components/feedback/FullPageLoader';
import { AppShell } from '../components/layout/AppShell';
import { ProtectedRoute } from '../features/auth/ProtectedRoute';
import { ForgotPasswordPage } from '../pages/ForgotPasswordPage';
import { HomePage } from '../pages/HomePage';
import { NotFoundPage } from '../pages/NotFoundPage';
import { ProfilePage } from '../pages/ProfilePage';
import { ResetPasswordPage } from '../pages/ResetPasswordPage';
import { SignInPage } from '../pages/SignInPage';
import { SystemStatusPage } from '../pages/SystemStatusPage';
import { UnauthorizedPage } from '../pages/UnauthorizedPage';
import { AiAdvisorPage } from '../pages/workspace/AiAdvisorPage';
import { CasesPage } from '../pages/workspace/CasesPage';
import { IncidentsPage } from '../pages/workspace/IncidentsPage';
import { OperationsPage } from '../pages/workspace/OperationsPage';
import { PermissionAdminPage } from '../pages/workspace/PermissionAdminPage';
import { WorkspacePage } from '../pages/workspace/WorkspacePage';

export const routeDefinitions: RouteObject[] = [
  {
    path: '/',
    element: <AppShell />,
    errorElement: <RouteErrorPage />,
    hydrateFallbackElement: <FullPageLoader label="Loading route" />,
    children: [
      { index: true, element: <HomePage /> },
      { path: 'sign-in', element: <SignInPage /> },
      { path: 'forgot-password', element: <ForgotPasswordPage /> },
      { path: 'reset-password', element: <ResetPasswordPage /> },
      { path: 'unauthorized', element: <UnauthorizedPage /> },
      { path: 'system-status', element: <SystemStatusPage /> },
      {
        element: <ProtectedRoute />,
        children: [
          { path: 'workspace', element: <WorkspacePage /> },
          { path: 'cases', element: <CasesPage /> },
          { path: 'incidents', element: <IncidentsPage /> },
          { path: 'operations', element: <OperationsPage /> },
          { path: 'ai-advisor', element: <AiAdvisorPage /> },
          { path: 'profile', element: <ProfilePage /> },
        ],
      },
      {
        element: <ProtectedRoute roles={['admin']} />,
        children: [{ path: 'administration/permissions', element: <PermissionAdminPage /> }],
      },
      { path: '*', element: <NotFoundPage /> },
    ],
  },
];

export const browserRouter = createBrowserRouter(routeDefinitions);

export function createTestRouter(initialEntries: string[]) {
  return createMemoryRouter(routeDefinitions, { initialEntries });
}
