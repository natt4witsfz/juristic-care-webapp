import { createPublicEnvironment } from '@o83/backend';

export interface PublicEnvironmentSource {
  readonly VITE_APP_ENV?: string | undefined;
  readonly VITE_APP_VERSION?: string | undefined;
  readonly VITE_SUPABASE_URL?: string | undefined;
  readonly VITE_SUPABASE_PUBLISHABLE_KEY?: string | undefined;
}

export function readEnvironment(source?: PublicEnvironmentSource) {
  const resolvedSource = source ?? {
    VITE_APP_ENV: import.meta.env.VITE_APP_ENV,
    VITE_APP_VERSION: import.meta.env.VITE_APP_VERSION,
    VITE_SUPABASE_URL: import.meta.env.VITE_SUPABASE_URL,
    VITE_SUPABASE_PUBLISHABLE_KEY: import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY,
  };

  return createPublicEnvironment({
    appEnvironment: resolvedSource.VITE_APP_ENV,
    appVersion: resolvedSource.VITE_APP_VERSION,
    supabaseUrl: resolvedSource.VITE_SUPABASE_URL,
    supabasePublishableKey: resolvedSource.VITE_SUPABASE_PUBLISHABLE_KEY,
  });
}

let cachedEnvironment: ReturnType<typeof readEnvironment> | undefined;

export function getEnvironment() {
  cachedEnvironment ??= readEnvironment();
  return cachedEnvironment;
}
