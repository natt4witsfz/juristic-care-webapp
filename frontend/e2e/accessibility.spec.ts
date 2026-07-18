import AxeBuilder from '@axe-core/playwright';
import { expect, test } from '@playwright/test';

for (const path of [
  '/',
  '/sign-in',
  '/forgot-password',
  '/system-status',
  '/unknown-accessibility-route',
]) {
  test(`has no automatically detectable accessibility violations at ${path}`, async ({ page }) => {
    await page.goto(path);
    await expect(page.locator('main')).toBeVisible();
    const results = await new AxeBuilder({ page }).analyze();
    expect(results.violations).toEqual([]);
  });
}
