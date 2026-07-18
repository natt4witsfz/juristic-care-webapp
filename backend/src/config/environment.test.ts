import { describe, expect, it } from 'vitest';

import { createPublicEnvironment } from './environment';

describe('createPublicEnvironment', () => {
  it('accepts a browser-safe Supabase configuration', () => {
    const environment = createPublicEnvironment({
      appEnvironment: 'test',
      supabaseUrl: 'https://example.supabase.co',
      supabasePublishableKey: 'publishable-key',
    });

    expect(environment.appEnvironment).toBe('test');
  });

  it('rejects a missing publishable key', () => {
    expect(() =>
      createPublicEnvironment({
        appEnvironment: 'test',
        supabaseUrl: 'https://example.supabase.co',
        supabasePublishableKey: undefined,
      }),
    ).toThrow();
  });
});
