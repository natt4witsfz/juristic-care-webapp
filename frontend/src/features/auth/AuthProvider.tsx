import { useEffect, useMemo, useState, type PropsWithChildren } from 'react';

import { AuthContext, type AuthContextValue } from './AuthContext';
import { supabaseAuthGateway } from './gateway';
import type { AccessContext, AuthGateway, AuthUser } from './types';

interface AuthProviderProps extends PropsWithChildren {
  readonly gateway?: AuthGateway | undefined;
}

export function AuthProvider({ children, gateway = supabaseAuthGateway }: AuthProviderProps) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [access, setAccess] = useState<AccessContext | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    const apply = (snapshot: { user: AuthUser | null; access: AccessContext | null }) => {
      if (!active) return;
      setUser(snapshot.user);
      setAccess(snapshot.access);
      setError(null);
      setLoading(false);
    };
    const unsubscribe = gateway.subscribe(apply);
    gateway
      .getSnapshot()
      .then(apply)
      .catch((cause: unknown) => {
        if (!active) return;
        setError(cause instanceof Error ? cause.message : 'Unable to restore the session.');
        setLoading(false);
      });
    return () => {
      active = false;
      unsubscribe();
    };
  }, [gateway]);

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      access,
      loading,
      error,
      signIn: gateway.signIn,
      signOut: gateway.signOut,
      requestPasswordReset: gateway.requestPasswordReset,
      updatePassword: gateway.updatePassword,
      hasPermission: (permission) => access?.permissions.includes(permission) ?? false,
      hasAnyRole: (roles) => access?.roles.some((role) => roles.includes(role)) ?? false,
    }),
    [access, error, gateway, loading, user],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
