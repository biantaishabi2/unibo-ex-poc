import { test, expect } from '@playwright/test';

test.describe("scheduling_constraint_list", () => {
  test('DTO smoke', async ({ page }) => {
    await page.goto("http://localhost:4002/scheduling/scheduling_constraint_list");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await expect(page.locator(`#page_title`)).toContainText(`排班约束配置`, { timeout: 15000 });
  });

  test('E2E flow', async ({ page }) => {
    const __memo = new Map();
    await page.goto("http://localhost:4002/scheduling/scheduling_constraint_list");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await test.step("页面加载 + 结构可见", async () => {
      await expect(page.locator(`[data-page='scheduling_constraint_list']`)).toBeVisible({ timeout: 15000 });
    });
    await test.step("新建导航", async () => {
      {
        const loc = page.locator(`#scheduling_constraint_create_btn, [data-action='navigate_create']`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
      try {
        await page.waitForFunction((v) => window.location.href.includes(v), "/scheduling/scheduling_constraint/new", { timeout: 15000 });
      } catch (e) {
        await page.waitForURL((url) => url.toString().includes("/scheduling/scheduling_constraint/new"), { timeout: 15000 });
      }
    });
    await test.step("表格行存在", async () => {
      await expect(page.locator(`#scheduling_constraint_table, [data-table='scheduling_constraint']`)).toBeVisible({ timeout: 15000 });
    });
  });
});
