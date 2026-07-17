import { defineConfig, devices } from '@playwright/test';

const port = 4175;
const browserUse = process.env.CI
  ? devices['Desktop Chrome']
  : { ...devices['Desktop Chrome'], channel: 'chrome' };

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: process.env.CI ? [['line'], ['html', { open: 'never' }]] : 'list',
  use: {
    baseURL: `http://127.0.0.1:${port}`,
    trace: 'on-first-retry',
  },
  projects: [{ name: 'chromium', use: browserUse }],
  webServer: {
    command: `vite --host 127.0.0.1 --port ${port}`,
    port,
    reuseExistingServer: !process.env.CI,
    timeout: 30_000,
    env: {
      VITE_APP_ENV: 'test',
      VITE_APP_VERSION: 'sprint-00-e2e',
      VITE_SUPABASE_URL: 'http://127.0.0.1:54321',
      VITE_SUPABASE_PUBLISHABLE_KEY: 'local-e2e-publishable-key',
    },
  },
});
