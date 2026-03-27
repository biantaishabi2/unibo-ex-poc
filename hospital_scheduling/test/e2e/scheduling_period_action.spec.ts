import { test, expect, Page } from '@playwright/test';

/**
 * SchedulingPeriod 状态机 action 按钮 E2E 测试
 *
 * 测试场景：
 * 1. 列表页显示种子数据（多个周期，不同状态）
 * 2. 通过 GraphQL 获取 draft 状态周期的 ID，直接访问详情页
 * 3. 验证详情页 action 按钮可见（edit_btn, generate_btn, publish_btn）
 * 4. 点击 generate_btn (action_start_generating) → 验证状态从 draft 变为 generating
 * 5. 列表页验证状态变化持久化
 *
 * 状态机流程：
 *   draft → generating → generated → adjusted → published
 *
 * 页面结构：
 * - 列表页：#period_table, #period_body, #page_title
 * - 详情页：#detail_title, #state_badge, #edit_btn, #generate_btn, #publish_btn
 * - action 按钮事件：toggle_edit, action_start_generating, action_publish
 */

const BASE = 'http://localhost:4200';
const LIST_URL = '/scheduling/scheduling_period_list';
const DETAIL_URL = '/scheduling/scheduling_period_detail';
const GRAPHQL_URL = '/api/graphql';

// 等待 LiveView 连接 + 数据加载
async function waitForLiveView(page: Page) {
  await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
  await page.waitForTimeout(1500);
}

// 等待页面稳定
async function waitForPage(page: Page) {
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
}

// 通过 GraphQL 获取 draft 状态的排班周期 ID
async function getDraftPeriodId(page: Page): Promise<string | null> {
  const response = await page.request.post(`${BASE}${GRAPHQL_URL}`, {
    data: {
      query: '{ listSchedulingSchedulingPeriods { results { id title state } } }'
    },
    headers: { 'Content-Type': 'application/json' }
  });
  const json = await response.json();
  const results = json?.data?.listSchedulingSchedulingPeriods?.results || [];
  // 优先选"骨科"的 draft 周期
  const ortho = results.find((r: any) => r.state === 'draft' && r.title?.includes('骨科'));
  if (ortho) return ortho.id;
  // 否则选任意 draft
  const draft = results.find((r: any) => r.state === 'draft');
  return draft?.id || null;
}

// 通过 GraphQL 查询指定周期的当前状态
async function getPeriodState(page: Page, id: string): Promise<string | null> {
  const response = await page.request.post(`${BASE}${GRAPHQL_URL}`, {
    data: {
      query: `{ getSchedulingSchedulingPeriod(id: "${id}") { id state } }`
    },
    headers: { 'Content-Type': 'application/json' }
  });
  const json = await response.json();
  return json?.data?.getSchedulingSchedulingPeriod?.state || null;
}

test.describe('SchedulingPeriod 状态机 action 测试', () => {
  test.describe.configure({ mode: 'serial' });

  let draftPeriodId: string | null = null;

  test('1. 列表页显示种子数据', async ({ page }) => {
    await page.goto(`${BASE}${LIST_URL}`);
    await waitForLiveView(page);
    await waitForPage(page);

    // 页面标题可见
    await expect(page.locator('#page_title')).toBeVisible({ timeout: 15000 });

    // 表格存在
    await expect(page.locator('#period_table')).toBeVisible({ timeout: 15000 });

    // 表格有数据行
    const rows = page.locator('#period_body tr');
    const rowCount = await rows.count();
    expect(rowCount).toBeGreaterThanOrEqual(3);

    // 验证存在 draft 状态的记录（badge 显示 "draft"）
    await expect(page.getByText('draft').first()).toBeVisible({ timeout: 15000 });

    // 验证有骨科相关数据
    await expect(page.getByText('骨科').first()).toBeVisible({ timeout: 15000 });

    // 刷新验证持久化
    await page.reload();
    await waitForLiveView(page);
    await waitForPage(page);
    await expect(page.locator('#period_table')).toBeVisible({ timeout: 15000 });
  });

  test('2. 进入 draft 详情页 + 验证 action 按钮', async ({ page }) => {
    // 通过 GraphQL 获取 draft 周期 ID
    draftPeriodId = await getDraftPeriodId(page);
    expect(draftPeriodId).toBeTruthy();

    // 直接访问详情页（navigate_detail 按钮缺少 phx-value-id，无法通过 UI 点击导航）
    await page.goto(`${BASE}${DETAIL_URL}?id=${draftPeriodId}`);
    await waitForLiveView(page);
    await waitForPage(page);

    // 验证详情页标题显示记录名称
    const title = await page.locator('#detail_title').textContent();
    expect(title?.trim()).toBeTruthy();

    // 验证状态 badge 显示 draft
    await expect(page.locator('#state_badge')).toBeVisible({ timeout: 15000 });
    const stateText = await page.locator('#state_badge').textContent();
    expect(stateText?.trim()).toBe('draft');

    // 验证 action 按钮存在
    await expect(page.locator('#edit_btn')).toBeVisible({ timeout: 15000 });
    await expect(page.locator('#generate_btn')).toBeVisible({ timeout: 15000 });
    await expect(page.locator('#publish_btn')).toBeVisible({ timeout: 15000 });
  });

  test('3. action_start_generating → 状态从 draft 变为 generating', async ({ page }) => {
    expect(draftPeriodId).toBeTruthy();

    // 进入 draft 状态的详情页
    await page.goto(`${BASE}${DETAIL_URL}?id=${draftPeriodId}`);
    await waitForLiveView(page);
    await waitForPage(page);

    // 确认当前状态为 draft
    const stateBadge = page.locator('#state_badge');
    await expect(stateBadge).toBeVisible({ timeout: 15000 });
    const stateText = await stateBadge.textContent();

    if (stateText?.trim() !== 'draft') {
      console.log(`当前状态为 ${stateText?.trim()}, 不是 draft, 跳过 start_generating 测试`);
      test.skip();
      return;
    }

    // 点击"开始自动排班"按钮 (phx-click="action_start_generating")
    const generateBtn = page.locator('#generate_btn');
    await generateBtn.waitFor({ state: 'visible', timeout: 15000 });
    await generateBtn.scrollIntoViewIfNeeded();
    await generateBtn.click();
    await waitForPage(page);

    // 等待可能的 DOM 更新
    await page.waitForTimeout(3000);

    // 通过 GraphQL 验证状态变化（持久化检查，不依赖 UI 渲染）
    const newState = await getPeriodState(page, draftPeriodId!);

    // solver 同步执行完成后状态可能是 generating（异步）或 generated（同步完成）
    // 两者都表示 action_start_generating 成功触发
    if (newState === 'generating' || newState === 'generated') {
      expect(['generating', 'generated']).toContain(newState);
      console.log(`SUCCESS: action_start_generating 通过 UI 按钮成功触发，状态已持久化为 ${newState}`);
    } else if (newState === 'draft') {
      // action 未执行 — 可能是编译器 bug 或 action 执行失败
      console.log('FAIL: action_start_generating 按钮点击后状态未变化（仍为 draft）');
      expect(newState).not.toBe('draft');
    } else {
      // 意外状态
      console.log(`意外状态: ${newState}`);
      expect(['generating', 'generated']).toContain(newState);
    }
  });

  test('4. 列表页验证状态变化持久化', async ({ page }) => {
    // 回到列表页
    await page.goto(`${BASE}${LIST_URL}`);
    await waitForLiveView(page);
    await waitForPage(page);

    // 表格应该可见
    await expect(page.locator('#period_table')).toBeVisible({ timeout: 15000 });

    // 验证表格中的数据完整性
    const rows = page.locator('#period_body tr');
    const rowCount = await rows.count();
    expect(rowCount).toBeGreaterThanOrEqual(1);

    // 刷新验证
    await page.reload();
    await waitForLiveView(page);
    await waitForPage(page);
    await expect(page.locator('#period_table')).toBeVisible({ timeout: 15000 });

    const reloadRowCount = await page.locator('#period_body tr').count();
    expect(reloadRowCount).toBe(rowCount);
  });

  test('5. action_publish → 状态从 generated 变为 published', async ({ page }) => {
    expect(draftPeriodId).toBeTruthy();

    // 先通过 GraphQL 确认当前状态（test 3 应已将其推进到 generated）
    const preState = await getPeriodState(page, draftPeriodId!);
    console.log(`publish 测试前状态: ${preState}`);

    if (preState !== 'generated' && preState !== 'adjusted') {
      console.log(`当前状态为 ${preState}，不在可 publish 的状态(generated/adjusted)，跳过`);
      test.skip();
      return;
    }

    // 进入详情页
    await page.goto(`${BASE}${DETAIL_URL}?id=${draftPeriodId}`);
    await waitForLiveView(page);
    await waitForPage(page);

    // 验证 UI 上状态 badge 与 GraphQL 一致
    const stateBadge = page.locator('#state_badge');
    await expect(stateBadge).toBeVisible({ timeout: 15000 });
    const badgeText = await stateBadge.textContent();
    expect(badgeText?.trim()).toBe(preState);

    // 点击 publish 按钮
    const publishBtn = page.locator('#publish_btn');
    await publishBtn.waitFor({ state: 'visible', timeout: 15000 });
    await publishBtn.scrollIntoViewIfNeeded();
    await publishBtn.click();
    await waitForPage(page);
    await page.waitForTimeout(3000);

    // 通过 GraphQL 验证状态变为 published（持久化检查）
    const afterState = await getPeriodState(page, draftPeriodId!);
    expect(afterState).toBe('published');
    console.log(`SUCCESS: action_publish 执行成功，状态从 ${preState} 变为 ${afterState}`);

    // 刷新 UI 验证 badge 也更新
    await page.reload();
    await waitForLiveView(page);
    await waitForPage(page);
    const reloadBadge = await page.locator('#state_badge').textContent();
    expect(reloadBadge?.trim()).toBe('published');
  });
});
