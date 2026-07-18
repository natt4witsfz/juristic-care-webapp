import { lazy, Suspense, type ComponentType, type ReactElement } from 'react';
import { createBrowserRouter, createMemoryRouter, type RouteObject } from 'react-router-dom';

import { RouteErrorPage } from '../components/feedback/RouteErrorPage';
import { FullPageLoader } from '../components/feedback/FullPageLoader';
import { AppShell } from '../components/layout/AppShell';
import { ProtectedRoute } from '../features/auth/ProtectedRoute';
import { ForgotPasswordPage } from '../pages/ForgotPasswordPage';
import { HomePage } from '../pages/HomePage';
import { NotFoundPage } from '../pages/NotFoundPage';
import { ResetPasswordPage } from '../pages/ResetPasswordPage';
import { SignInPage } from '../pages/SignInPage';
import { SystemStatusPage } from '../pages/SystemStatusPage';
import { UnauthorizedPage } from '../pages/UnauthorizedPage';

function routeComponent<T extends Record<string, ComponentType>>(
  loader: () => Promise<T>,
  name: keyof T,
) {
  return lazy(async () => ({ default: (await loader())[name] }));
}

function page(Component: ComponentType): ReactElement {
  return (
    <Suspense fallback={<FullPageLoader label="Loading workspace" />}>
      <Component />
    </Suspense>
  );
}

const WorkspacePage = routeComponent(
  () => import('../pages/workspace/WorkspacePage'),
  'WorkspacePage',
);
const CasesPage = routeComponent(() => import('../pages/workspace/CasesPage'), 'CasesPage');
const InvestigationsPage = routeComponent(
  () => import('../pages/workspace/InvestigationsPage'),
  'InvestigationsPage',
);
const IncidentsPage = routeComponent(
  () => import('../pages/workspace/IncidentsPage'),
  'IncidentsPage',
);
const OperationsPage = routeComponent(
  () => import('../pages/workspace/OperationsPage'),
  'OperationsPage',
);
const EvidencePage = routeComponent(
  () => import('../pages/workspace/EvidencePage'),
  'EvidencePage',
);
const NotificationsPage = routeComponent(
  () => import('../pages/workspace/NotificationsPage'),
  'NotificationsPage',
);
const ReportsPage = routeComponent(() => import('../pages/workspace/ReportsPage'), 'ReportsPage');
const OfflineContinuityPage = routeComponent(
  () => import('../pages/workspace/OfflineContinuityPage'),
  'OfflineContinuityPage',
);
const TimelinePage = routeComponent(
  () => import('../pages/workspace/TimelinePage'),
  'TimelinePage',
);
const AiAdvisorPage = routeComponent(
  () => import('../pages/workspace/AiAdvisorPage'),
  'AiAdvisorPage',
);
const ProfilePage = routeComponent(() => import('../pages/ProfilePage'), 'ProfilePage');
const PermissionAdminPage = routeComponent(
  () => import('../pages/workspace/PermissionAdminPage'),
  'PermissionAdminPage',
);

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
          { path: 'workspace', element: page(WorkspacePage) },
          { path: 'cases', element: page(CasesPage) },
          { path: 'investigations', element: page(InvestigationsPage) },
          { path: 'incidents', element: page(IncidentsPage) },
          { path: 'operations', element: page(OperationsPage) },
          { path: 'evidence', element: page(EvidencePage) },
          { path: 'notifications', element: page(NotificationsPage) },
          { path: 'reports', element: page(ReportsPage) },
          { path: 'offline', element: page(OfflineContinuityPage) },
          { path: 'timeline', element: page(TimelinePage) },
          { path: 'ai-advisor', element: page(AiAdvisorPage) },
          { path: 'profile', element: page(ProfilePage) },
        ],
      },
      {
        element: <ProtectedRoute roles={['admin']} />,
        children: [{ path: 'administration/permissions', element: page(PermissionAdminPage) }],
      },
      { path: '*', element: <NotFoundPage /> },
    ],
  },
];

export const browserRouter = createBrowserRouter(routeDefinitions);

export function createTestRouter(initialEntries: string[]) {
  return createMemoryRouter(routeDefinitions, { initialEntries });
}
