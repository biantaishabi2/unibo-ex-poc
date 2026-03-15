import { test, expect } from '@playwright/test';

test.describe("calendar_adjustment", () => {
  test('DTO smoke', async ({ page }) => {
    await page.goto("http://localhost:4002/scheduling/calendar_adjustment");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await expect(page.locator(`#coverage_value`)).toContainText(`%`, { timeout: 15000 });
  });

  test('E2E flow', async ({ page }) => {
    const __memo = new Map();
    await page.goto("http://localhost:4002/scheduling/calendar_adjustment");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await test.step("页面加载 + 日历表格可见", async () => {
      await expect(page.locator(`#calendar_table`)).toBeVisible({ timeout: 15000 });
      await expect(page.locator(`#period_badge`)).toBeVisible({ timeout: 15000 });
      await expect(page.locator(`#coverage_value`)).toBeVisible({ timeout: 15000 });
    });
    await test.step("周导航 - 上一周", async () => {
      {
        const loc = page.locator(`#prev_week_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      await expect(page.locator(`#current_week_label`)).toBeVisible({ timeout: 15000 });
    });
    await test.step("周导航 - 下一周", async () => {
      {
        const loc = page.locator(`#next_week_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      await expect(page.locator(`#current_week_label`)).toBeVisible({ timeout: 15000 });
    });
    await test.step("保存草稿", async () => {
      {
        const loc = page.locator(`#save_draft_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      await expect(page.locator(`#flash-group, [data-flash], [role='alert']`)).toContainText(`保存`, { timeout: 15000 });
    });
    await test.step("跳转发布预览", async () => {
      {
        const loc = page.locator(`#publish_preview_btn`);
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
