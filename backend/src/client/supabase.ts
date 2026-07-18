import { createClient, type SupabaseClient } from '@supabase/supabase-js';

import type { PublicEnvironment } from '../config/environment';

export function createBrowserSupabaseClient(environment: PublicEnvironment): SupabaseClient {
  return createClient(environment.supabaseUrl, environment.supabasePublishableKey, {
    auth: {
      autoRefreshToken: true,
      detectSessionInUrl: true,
      persistSession: true,
    },
  });
}
