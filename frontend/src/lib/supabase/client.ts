import { createBrowserSupabaseClient } from '@o83/backend';

import { getEnvironment } from '../../config/environment';

let client: ReturnType<typeof createBrowserSupabaseClient> | undefined;

export function getSupabaseClient() {
  client ??= createBrowserSupabaseClient(getEnvironment());
  return client;
}
