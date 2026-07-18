import { PublicEnvironmentError } from '@o83/backend';

import { readEnvironment } from './environment';

describe('readEnvironment', () => {
  it('accepts valid public configuration and its optional version', () => {
    const environment = readEnvironment({
      VITE_APP_ENV: 'test',
      VITE_APP_VERSION: 'sprint-00',
      VITE_SUPABASE_URL: 'http://127.0.0.1:54321',
      VITE_SUPABASE_PUBLISHABLE_KEY: 'browser-safe-test-key',
    });

    expect(environment.appVersion).toBe('sprint-00');
  });

  it('fails clearly when required public configuration is missing', () => {
    expect(() => readEnvironment({ VITE_APP_ENV: 'test' })).toThrow(PublicEnvironmentError);
  });
});
