import { createContext } from 'react';

import type { AccessContext, AuthGateway, AuthUser } from './types';

export interface AuthContextValue {
  readonly user: AuthUser | null;
  readonly access: AccessContext | null;
  readonly loading: boolean;
  readonly error: string | null;
  readonly signIn: AuthGateway['signIn'];
  readonly signOut: AuthGateway['signOut'];
  readonly requestPasswordReset: AuthGateway['requestPasswordReset'];
  readonly updatePassword: AuthGateway['updatePassword'];
  hasPermission(permission: string): boolean;
  hasAnyRole(roles: readonly string[]): boolean;
}

export const AuthContext = createContext<AuthContextValue | null>(null);
