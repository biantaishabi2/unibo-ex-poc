import { test, expect } from '@playwright/test';

test.describe("requirement_matrix", () => {
  test('DTO smoke', async ({ page }) => {
    await page.goto("http://localhost:4002/scheduling/requirement_matrix");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await expect(page.locator(`#page_title`)).toContainText(`需求矩阵`, { timeout: 15000 });
    await expect(page.locator(`#date_range`)).toContainText(`~`, { timeout: 15000 });
  });

  test('E2E flow', async ({ page }) => {
    const __memo = new Map();
    await page.goto("http://localhost:4002/scheduling/requirement_matrix");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await test.step("页面加载 + 矩阵表格可见", async () => {
      await expect(page.locator(`#req_matrix_table`)).toBeVisible({ timeout: 15000 });
      await expect(page.locator(`#page_title`)).toBeVisible({ timeout: 15000 });
      await expect(page.locator(`#state_badge`)).toBeVisible({ timeout: 15000 });
    });
    await test.step("批量填充需求", async () => {
      {
        const loc = page.locator(`#batch_fill_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      await expect(page.locator(`#req_matrix_table`)).toBeVisible({ timeout: 15000 });
    });
    await test.step("保存需求", async () => {
      {
        const loc = page.locator(`#save_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      await expect(page.locator(`#flash-group, [data-flash], [role='alert']`)).toContainText(`保存`, { timeout: 15000 });
    });
    await test.step("开始生成排班", async () => {
      {
        const loc = page.locator(`#start_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      await expect(page.locator(`#flash-group, [data-flash], [role='alert']`)).toContainText(`生成`, { timeout: 15000 });
    });
  });
});
