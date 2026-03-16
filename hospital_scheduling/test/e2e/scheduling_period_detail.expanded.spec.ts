import { test, expect } from '@playwright/test';

test.describe("scheduling_period_detail", () => {
  test('DTO smoke', async ({ page }) => {
    await page.goto("http://localhost:4200/scheduling/scheduling_period_detail?id=9c0d406d-58d3-4e36-99c5-c18846d9d483");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await expect(page.locator(`#date_value`)).toContainText(`~`, { timeout: 15000 });
    await expect(page.locator(`#version_value`)).toContainText(`v`, { timeout: 15000 });
  });

  test('E2E flow', async ({ page }) => {
    const __memo = new Map();
    await page.goto("http://localhost:4200/scheduling/scheduling_period_detail?id=9c0d406d-58d3-4e36-99c5-c18846d9d483");
    // Avoid relying on window.liveSocket (apps may not expose it).
    // Waiting for the LiveView root to be present is enough for our contract regression tests.
    await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
    await page.waitForTimeout(150);
    await test.step("动作冒烟：action_start_generating", async () => {
      {
        const loc = page.locator(`#generate_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
    });
    await test.step("动作冒烟：action_publish", async () => {
      {
        const loc = page.locator(`#publish_btn`);
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        await loc.scrollIntoViewIfNeeded();
        await loc.click({ timeout: 15000 });
      }
    });
  });
});
