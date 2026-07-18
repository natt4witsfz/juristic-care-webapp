import type { AuthGateway, AuthSnapshot } from '../features/auth/types';

export function createAuthGateway(
  snapshot: AuthSnapshot = { user: null, access: null },
): AuthGateway {
  return {
    getSnapshot: async () => snapshot,
    subscribe: () => () => undefined,
    signIn: async () => undefined,
    signOut: async () => undefined,
    requestPasswordReset: async () => undefined,
    updatePassword: async () => undefined,
  };
}
