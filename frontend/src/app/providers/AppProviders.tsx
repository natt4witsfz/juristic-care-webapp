import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useState, type PropsWithChildren } from 'react';

import { AuthProvider } from '../../features/auth/AuthProvider';
import type { AuthGateway } from '../../features/auth/types';

interface AppProvidersProps extends PropsWithChildren {
  readonly authGateway?: AuthGateway | undefined;
}

export function AppProviders({ children, authGateway }: AppProvidersProps) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            retry: 1,
            staleTime: 30_000,
            refetchOnWindowFocus: false,
          },
          mutations: {
            retry: 0,
          },
        },
      }),
  );

  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider gateway={authGateway}>{children}</AuthProvider>
    </QueryClientProvider>
  );
}
