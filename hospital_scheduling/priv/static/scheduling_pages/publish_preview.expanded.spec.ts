import { test, expect } from '@playwright/test';

test.describe("publish_preview", () => {
  test('DTO smoke', async ({ page }) => {
    await page.goto("http://localhost:4002/scheduling/publish_preview");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await expect(page.locator(`#page_title`)).toContainText(`发布预览 —`, { timeout: 15000 });
    await expect(page.locator(`#version_badge`)).toContainText(`v`, { timeout: 15000 });
    await expect(page.locator(`#coverage_value`)).toContainText(`%`, { timeout: 15000 });
  });

  test('E2E flow', async ({ page }) => {
    const __memo = new Map();
    await page.goto("http://localhost:4002/scheduling/publish_preview");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await test.step("页面加载 + 差异表可见", async () => {
      await expect(page.locator(`#diff_table`)).toBeVisible({ timeout: 15000 });
      await expect(page.locator(`#version_badge`)).toBeVisible({ timeout: 15000 });
      await expect(page.locator(`#coverage_value`)).toBeVisible({ timeout: 15000 });
    });
    await test.step("切换差异模式", async () => {
      {
        const loc = page.locator(`#toggle_diff_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      await expect(page.locator(`#diff_table`)).toBeVisible({ timeout: 15000 });
    });
    await test.step("发布（无硬违规时可点击）", async () => {
      await expect(page.locator(`#publish_btn`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#publish_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      await expect(page.locator(`#flash-group, [data-flash], [role='alert']`)).toContainText(`发布`, { timeout: 15000 });
    });
    await test.step("返回上一页", async () => {
      {
        const loc = page.locator(`#back_btn, #cancel_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
    });
  });
});
