import { test, expect } from '@playwright/test';

test.describe("shift_type_detail", () => {
  test('DTO smoke', async ({ page }) => {
    await page.goto("http://localhost:4002/scheduling/shift_type_detail");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await expect(page.locator(`#shift_type_bc_current`)).toContainText(`详情`, { timeout: 15000 });
  });

  test('E2E flow', async ({ page }) => {
    const __memo = new Map();
    await page.goto("http://localhost:4002/scheduling/shift_type_detail");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await test.step("页面加载 + 结构可见", async () => {
      await expect(page.locator(`[data-page='shift_type_detail']`)).toBeVisible({ timeout: 15000 });
    });
    await test.step("编辑模式切换", async () => {
      {
        const loc = page.locator(`[data-action='toggle_edit']`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      await expect(page.locator(`form, [data-mode='edit']`)).toBeVisible({ timeout: 15000 });
    });
    await test.step("表单提交", async () => {
      {
        const loc = page.locator(`[data-action='form_submit'], button[type='submit']`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      await expect(page.locator(`#flash-group, [data-flash], [role='alert']`)).toContainText(`成功`, { timeout: 15000 });
    });
  });
});
