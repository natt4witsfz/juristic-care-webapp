import { Suspense, type ComponentProps } from 'react';
import { RouterProvider } from 'react-router-dom';

import { ErrorBoundary } from '../components/feedback/ErrorBoundary';
import { FullPageLoader } from '../components/feedback/FullPageLoader';
import { AppProviders } from './providers/AppProviders';
import { browserRouter } from '../routes/router';
import type { AuthGateway } from '../features/auth/types';

interface AppProps {
  readonly router?: ComponentProps<typeof RouterProvider>['router'];
  readonly authGateway?: AuthGateway | undefined;
}

export function App({ authGateway, router = browserRouter }: AppProps) {
  return (
    <ErrorBoundary>
      <AppProviders authGateway={authGateway}>
        <Suspense fallback={<FullPageLoader label="Loading route" />}>
          <RouterProvider router={router} />
        </Suspense>
      </AppProviders>
    </ErrorBoundary>
  );
}
