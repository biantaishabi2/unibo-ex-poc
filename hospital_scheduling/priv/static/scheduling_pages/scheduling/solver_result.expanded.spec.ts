import { test, expect } from '@playwright/test';

test.describe("solver_result", () => {
  test('DTO smoke', async ({ page }) => {
    await page.goto("http://localhost:4002/scheduling/solver_result");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await expect(page.locator(`#page_title`)).toContainText(`排班结果 —`, { timeout: 15000 });
    await expect(page.locator(`#engine_info`)).toContainText(`算法:`, { timeout: 15000 });
  });

  test('E2E flow', async ({ page }) => {
    const __memo = new Map();
    await page.goto("http://localhost:4002/scheduling/solver_result");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await test.step("页面加载 + KPI 和违规表可见", async () => {
      await expect(page.locator(`#page_title`)).toBeVisible({ timeout: 15000 });
      await expect(page.locator(`#run_status_badge`)).toBeVisible({ timeout: 15000 });
      await expect(page.locator(`#engine_info`)).toBeVisible({ timeout: 15000 });
      await expect(page.locator(`#violations_table`)).toBeVisible({ timeout: 15000 });
    });
    await test.step("跳转日历调班", async () => {
      {
        const loc = page.locator(`#calendar_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      try {
        await page.waitForFunction((v) => window.location.href.includes(v), "/scheduling/calendar_adjustment", { timeout: 15000 });
      } catch (e) {
        await page.waitForURL((url) => url.toString().includes("/scheduling/calendar_adjustment"), { timeout: 15000 });
      }
    });
    await test.step("跳转发布预览", async () => {
      {
        const loc = page.locator(`#publish_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      try {
        await page.waitForFunction((v) => window.location.href.includes(v), "/scheduling/publish_preview", { timeout: 15000 });
      } catch (e) {
        await page.waitForURL((url) => url.toString().includes("/scheduling/publish_preview"), { timeout: 15000 });
      }
    });
  });
});
