import { expect, test } from '@playwright/test';

test('serves the home workspace and status route', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: /clear operational care/i })).toBeVisible();

  await page.getByRole('link', { name: /system status/i }).click();
  await expect(page.getByRole('heading', { name: /system status/i })).toBeVisible();
  await expect(page.getByText('sprint-00-e2e')).toBeVisible();
});

test('returns an accessible not-found page for an unknown client route', async ({ page }) => {
  await page.goto('/unknown-sprint-00-route');
  await expect(page.getByRole('heading', { name: /page not found/i })).toBeVisible();
  await expect(page.getByRole('link', { name: /return to workspace/i })).toBeVisible();
});
