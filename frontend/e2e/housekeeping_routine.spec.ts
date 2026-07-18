import { expect, test } from '@playwright/test';

test.beforeEach(async ({ page }) => {
  await page.goto('/prototype/housekeeping-routine');
  await page.evaluate(() => window.localStorage.removeItem('o83.housekeeping_routine.mock.v0_1'));
  await page.reload();
});

test('approves work, persists across refresh, and resets demo data', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Housekeeping Routine Control' })).toBeVisible();

  await page.getByRole('button', { name: /HK-02 ทำความสะอาด Lobby รอตรวจ เปิดหลักฐาน/ }).click();
  await expect(page.getByRole('dialog', { name: 'Inspection Drawer' })).toBeVisible();
  await page.getByRole('button', { name: 'อนุมัติ', exact: true }).click();
  await page.getByRole('button', { name: 'ยืนยันอนุมัติ', exact: true }).click();
  await expect(
    page.getByRole('button', { name: /HK-02 ทำความสะอาด Lobby ผ่านแล้ว เปิดหลักฐาน/ }),
  ).toBeVisible();

  await page.reload();
  await expect(
    page.getByRole('button', { name: /HK-02 ทำความสะอาด Lobby ผ่านแล้ว เปิดหลักฐาน/ }),
  ).toBeVisible();
  await page.getByRole('button', { name: 'Reset Demo Data' }).click();
  await page.getByRole('button', { name: 'ยืนยัน Reset' }).click();
  await expect(
    page.getByRole('button', { name: /HK-02 ทำความสะอาด Lobby รอตรวจ เปิดหลักฐาน/ }),
  ).toBeVisible();
});

test('shows effective-dated HK-03 employee history', async ({ page }) => {
  await page.getByRole('button', { name: 'ประวัติตำแหน่ง Position History', exact: true }).click();

  const asOfDate = page.getByRole('combobox', {
    name: 'ดูข้อมูล ณ วันที่ / As of',
    exact: true,
  });
  await asOfDate.selectOption('2026-06-15');
  await expect(page.getByRole('heading', { name: 'อรุณี เดโม' })).toBeVisible();
  await asOfDate.selectOption('2026-07-18');
  await expect(page.getByRole('heading', { name: 'เบญจา เดโม' })).toBeVisible();
  await asOfDate.selectOption('2026-08-15');
  await expect(page.getByRole('heading', { name: 'สายฝน เดโม' })).toBeVisible();
});
