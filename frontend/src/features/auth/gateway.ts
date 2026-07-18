import { getSupabaseClient } from '../../lib/supabase/client';
import type { AccessContext, AuthGateway, AuthSnapshot, AuthUser, O83Role } from './types';

interface AccessRow {
  juristic_person_id: string;
  person_id: string;
  display_name: string;
  roles: O83Role[] | null;
  permissions: string[] | null;
}

function toUser(user: { id: string; email?: string | null } | null): AuthUser | null {
  return user ? { id: user.id, email: user.email ?? null } : null;
}

async function resolveAccess(): Promise<AccessContext | null> {
  const client = getSupabaseClient();
  const { data, error } = await client.schema('api').rpc('resolve_current_access');
  if (error) throw new Error(`Unable to resolve organization access: ${error.message}`);
  const row = (Array.isArray(data) ? data[0] : data) as AccessRow | null;
  if (!row) return null;
  return {
    juristicPersonId: row.juristic_person_id,
    personId: row.person_id,
    displayName: row.display_name,
    roles: row.roles ?? [],
    permissions: row.permissions ?? [],
  };
}

async function snapshotFromCurrentSession(): Promise<AuthSnapshot> {
  const client = getSupabaseClient();
  const { data, error } = await client.auth.getSession();
  if (error) throw new Error(`Unable to restore session: ${error.message}`);
  const user = toUser(data.session?.user ?? null);
  return { user, access: user ? await resolveAccess() : null };
}

export const supabaseAuthGateway: AuthGateway = {
  getSnapshot: snapshotFromCurrentSession,
  subscribe(listener) {
    const client = getSupabaseClient();
    const { data } = client.auth.onAuthStateChange((_event, session) => {
      const user = toUser(session?.user ?? null);
      void (async () => {
        try {
          listener({ user, access: user ? await resolveAccess() : null });
        } catch {
          listener({ user, access: null });
        }
      })();
    });
    return () => data.subscription.unsubscribe();
  },
  async signIn(email, password) {
    const { error } = await getSupabaseClient().auth.signInWithPassword({ email, password });
    if (error) throw new Error(error.message);
  },
  async signOut() {
    const { error } = await getSupabaseClient().auth.signOut({ scope: 'local' });
    if (error) throw new Error(error.message);
  },
  async requestPasswordReset(email, redirectTo) {
    const { error } = await getSupabaseClient().auth.resetPasswordForEmail(email, { redirectTo });
    if (error) throw new Error(error.message);
  },
  async updatePassword(password) {
    const { error } = await getSupabaseClient().auth.updateUser({ password });
    if (error) throw new Error(error.message);
  },
};
