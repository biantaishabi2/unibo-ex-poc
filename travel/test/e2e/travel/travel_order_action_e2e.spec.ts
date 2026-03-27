/**
 * TravelOrder 状态机 action E2E 测试
 *
 * 覆盖 TravelOrder 生命周期状态流转（主流程）：
 *   draft -> quoted -> submitted -> booking_pending -> booked -> completed
 *
 * 以及分支流程：
 *   - booked -> cancel_pending -> cancelled（取消流程）
 *   - submitted -> failed（失败流程）
 *   - booked -> request_change(pending) -> confirm_change(changed)（改签流程）
 *
 * 测试策略：
 * 1. 通过 GraphQL mutation 创建前置数据（FlightOffer）
 * 2. 通过 GraphQL mutation 创建 TravelOrder（customerId 使用占位 UUID）
 * 3. 通过 GraphQL mutation 驱动状态流转并验证持久化
 *
 * 注意：Sales::Customer 的 GraphQL mutation 在当前 schema 中未暴露，
 * 因此 customerId 使用占位 UUID。TravelOrder 的 customer_id 关联验证
 * 不做外键约束检查，接受任意合法 UUID。
 */
import { test, expect } from '@playwright/test';

const BASE_URL = 'http://localhost:4100';
const GRAPHQL_URL = `${BASE_URL}/api/graphql`;
const TENANT_ID = '00000000-0000-0000-0000-000000000001';
const FAKE_CUSTOMER_ID = '00000000-0000-0000-0000-000000000099';

// ── GraphQL 辅助函数 ──

async function gql(query: string): Promise<any> {
  const resp = await fetch(GRAPHQL_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-tenant-id': TENANT_ID,
    },
    body: JSON.stringify({ query }),
  });
  const json = await resp.json();
  if (json.errors && json.errors.length > 0) {
    throw new Error(`GraphQL error: ${JSON.stringify(json.errors)}`);
  }
  return json.data;
}

/** 执行 GraphQL 变更，返回完整 response 包含 errors（不抛异常） */
async function gqlRaw(query: string): Promise<any> {
  const resp = await fetch(GRAPHQL_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-tenant-id': TENANT_ID,
    },
    body: JSON.stringify({ query }),
  });
  return resp.json();
}

/** 创建前置 FlightOffer */
async function createFlightOffer(): Promise<string> {
  const ts = Date.now();
  const data = await gql(`
    mutation {
      createTravelFlightOffer(input: {
        tenantId: "${TENANT_ID}"
        supplierCode: "ORDER-E2E-${ts}"
        itineraryCode: "IT-${ts}"
        flightNo: "MU${ts % 10000}"
        departureAirportCode: "PVG"
        arrivalAirportCode: "CAN"
        departureAt: "2026-09-01T06:00:00Z"
        arrivalAt: "2026-09-01T09:00:00Z"
        cabinClass: "business"
        listedPrice: "3500.00"
      }) {
        result { id }
        errors { message }
      }
    }
  `);
  return data.createTravelFlightOffer.result.id;
}

/** 创建 TravelOrder（使用占位 customerId） */
async function createTravelOrder(flightOfferId: string): Promise<string> {
  const ts = Date.now();
  const data = await gql(`
    mutation {
      createTravelTravelOrder(input: {
        tenantId: "${TENANT_ID}"
        orderNo: "ORD-E2E-${ts}"
        productType: "flight"
        flightOfferId: "${flightOfferId}"
        customerId: "${FAKE_CUSTOMER_ID}"
        contactName: "测试联系人"
        contactPhone: "13800000001"
        travelerCount: 1
        totalAmount: "3500.00"
        currency: "CNY"
      }) {
        result { id status }
        errors { message }
      }
    }
  `);
  const result = data.createTravelTravelOrder;
  if (result.errors && result.errors.length > 0) {
    throw new Error(`创建 TravelOrder 失败: ${JSON.stringify(result.errors)}`);
  }
  return result.result.id;
}

/** 查询 TravelOrder 状态 */
async function getOrderStatus(id: string): Promise<string> {
  const data = await gql(`
    query {
      getTravelTravelOrder(id: "${id}") {
        id
        status
      }
    }
  `);
  return data.getTravelTravelOrder.status;
}

/** 查询 TravelOrder 完整状态 */
async function getOrderFullStatus(id: string): Promise<{
  status: string;
  changeStatus: string;
  waitlistStatus: string;
}> {
  const data = await gql(`
    query {
      getTravelTravelOrder(id: "${id}") {
        id
        status
        changeStatus
        waitlistStatus
      }
    }
  `);
  return data.getTravelTravelOrder;
}

// ── 状态流转 mutation 辅助（使用已验证的 GraphQL mutation 名称） ──

async function confirmQuote(id: string): Promise<string> {
  const data = await gql(
    `mutation { confirmQuoteTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`
  );
  return data.confirmQuoteTravelTravelOrder.result.status;
}

async function submitOrder(id: string): Promise<string> {
  const data = await gql(
    `mutation { submitOrderTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`
  );
  return data.submitOrderTravelTravelOrder.result.status;
}

async function markPaymentSucceeded(id: string): Promise<string> {
  const data = await gql(
    `mutation { markPaymentSucceededTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`
  );
  return data.markPaymentSucceededTravelTravelOrder.result.status;
}

async function markBooked(id: string): Promise<string> {
  const data = await gql(
    `mutation { markBookedTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`
  );
  return data.markBookedTravelTravelOrder.result.status;
}

async function markCompleted(id: string): Promise<string> {
  const data = await gql(
    `mutation { markCompletedTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`
  );
  return data.markCompletedTravelTravelOrder.result.status;
}

async function requestCancel(id: string): Promise<string> {
  const data = await gql(
    `mutation { requestCancelTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`
  );
  return data.requestCancelTravelTravelOrder.result.status;
}

async function executeCancel(id: string): Promise<string> {
  const data = await gql(
    `mutation { executeCancelTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`
  );
  return data.executeCancelTravelTravelOrder.result.status;
}

async function markOrderFailed(id: string): Promise<string> {
  const data = await gql(
    `mutation { markOrderFailedTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`
  );
  return data.markOrderFailedTravelTravelOrder.result.status;
}

async function requestChange(id: string): Promise<string> {
  const data = await gql(
    `mutation { requestChangeTravelTravelOrder(id: "${id}", input: { originalOrderRef: "ORIG-001" }) { result { id status changeStatus } errors { message } } }`
  );
  return data.requestChangeTravelTravelOrder.result.changeStatus;
}

async function confirmChange(id: string): Promise<string> {
  const data = await gql(
    `mutation { confirmChangeTravelTravelOrder(id: "${id}") { result { id status changeStatus } errors { message } } }`
  );
  return data.confirmChangeTravelTravelOrder.result.changeStatus;
}

// ── 共享测试数据 ──

let sharedFlightOfferId: string | null = null;

async function ensureFlightOffer(): Promise<string> {
  if (!sharedFlightOfferId) {
    sharedFlightOfferId = await createFlightOffer();
  }
  return sharedFlightOfferId;
}

// ── 测试用例 ──

test.describe('TravelOrder 状态机 action E2E', () => {

  test.describe('主流程：draft -> quoted -> submitted -> booking_pending -> booked -> completed', () => {
    test('完整主流程状态流转', async () => {
      const flightOfferId = await ensureFlightOffer();
      const orderId = await createTravelOrder(flightOfferId);

      // Step 1: 初始状态 draft
      expect(await getOrderStatus(orderId)).toBe('draft');

      // Step 2: confirm_quote -> quoted
      expect(await confirmQuote(orderId)).toBe('quoted');
      expect(await getOrderStatus(orderId)).toBe('quoted');

      // Step 3: submit_order -> submitted
      expect(await submitOrder(orderId)).toBe('submitted');
      expect(await getOrderStatus(orderId)).toBe('submitted');

      // Step 4: mark_payment_succeeded -> booking_pending
      expect(await markPaymentSucceeded(orderId)).toBe('booking_pending');
      expect(await getOrderStatus(orderId)).toBe('booking_pending');

      // Step 5: mark_booked -> booked
      expect(await markBooked(orderId)).toBe('booked');
      expect(await getOrderStatus(orderId)).toBe('booked');

      // Step 6: mark_completed -> completed
      expect(await markCompleted(orderId)).toBe('completed');
      expect(await getOrderStatus(orderId)).toBe('completed');
    });
  });

  test.describe('取消流程：booked -> cancel_pending -> cancelled', () => {
    test('订单取消流程', async () => {
      const flightOfferId = await ensureFlightOffer();
      const orderId = await createTravelOrder(flightOfferId);

      // 快进到 booked 状态
      await confirmQuote(orderId);
      await submitOrder(orderId);
      await markPaymentSucceeded(orderId);
      await markBooked(orderId);
      expect(await getOrderStatus(orderId)).toBe('booked');

      // request_cancel -> cancel_pending
      expect(await requestCancel(orderId)).toBe('cancel_pending');
      expect(await getOrderStatus(orderId)).toBe('cancel_pending');

      // execute_cancel -> cancelled
      expect(await executeCancel(orderId)).toBe('cancelled');
      expect(await getOrderStatus(orderId)).toBe('cancelled');
    });
  });

  test.describe('失败流程：submitted -> failed', () => {
    test('订单失败流程', async () => {
      const flightOfferId = await ensureFlightOffer();
      const orderId = await createTravelOrder(flightOfferId);

      // 快进到 submitted
      await confirmQuote(orderId);
      await submitOrder(orderId);
      expect(await getOrderStatus(orderId)).toBe('submitted');

      // mark_order_failed -> failed
      expect(await markOrderFailed(orderId)).toBe('failed');
      expect(await getOrderStatus(orderId)).toBe('failed');
    });
  });

  test.describe('改签流程：booked -> request_change -> confirm_change', () => {
    test('订单改签流程', async () => {
      const flightOfferId = await ensureFlightOffer();
      const orderId = await createTravelOrder(flightOfferId);

      // 快进到 booked
      await confirmQuote(orderId);
      await submitOrder(orderId);
      await markPaymentSucceeded(orderId);
      await markBooked(orderId);

      // request_change -> change_status: pending
      const changeStatus = await requestChange(orderId);
      expect(changeStatus).toBe('pending');

      // confirm_change -> change_status: changed
      const confirmedChangeStatus = await confirmChange(orderId);
      expect(confirmedChangeStatus).toBe('changed');

      // 主 status 仍为 booked
      const fullStatus = await getOrderFullStatus(orderId);
      expect(fullStatus.status).toBe('booked');
      expect(fullStatus.changeStatus).toBe('changed');
    });
  });

  test.describe('非法状态流转拒绝', () => {
    test('draft 不能直接 submit_order', async () => {
      const flightOfferId = await ensureFlightOffer();
      const orderId = await createTravelOrder(flightOfferId);

      // Ash GraphQL 返回 result: null + errors（不是 HTTP 错误）
      const resp = await gqlRaw(
        `mutation { submitOrderTravelTravelOrder(id: "${orderId}") { result { id status } errors { message } } }`
      );
      const result = resp.data.submitOrderTravelTravelOrder;
      expect(result.result).toBeNull();
      expect(result.errors.length).toBeGreaterThan(0);

      // 状态应保持不变
      expect(await getOrderStatus(orderId)).toBe('draft');
    });

    test('quoted 不能直接 mark_booked', async () => {
      const flightOfferId = await ensureFlightOffer();
      const orderId = await createTravelOrder(flightOfferId);
      await confirmQuote(orderId);

      const resp = await gqlRaw(
        `mutation { markBookedTravelTravelOrder(id: "${orderId}") { result { id status } errors { message } } }`
      );
      const result = resp.data.markBookedTravelTravelOrder;
      expect(result.result).toBeNull();
      expect(result.errors.length).toBeGreaterThan(0);

      expect(await getOrderStatus(orderId)).toBe('quoted');
    });

    test('completed 订单不能再操作', async () => {
      const flightOfferId = await ensureFlightOffer();
      const orderId = await createTravelOrder(flightOfferId);

      // 快进到 completed
      await confirmQuote(orderId);
      await submitOrder(orderId);
      await markPaymentSucceeded(orderId);
      await markBooked(orderId);
      await markCompleted(orderId);

      // 不能再次 mark_completed
      const resp1 = await gqlRaw(
        `mutation { markCompletedTravelTravelOrder(id: "${orderId}") { result { id status } errors { message } } }`
      );
      expect(resp1.data.markCompletedTravelTravelOrder.result).toBeNull();
      expect(resp1.data.markCompletedTravelTravelOrder.errors.length).toBeGreaterThan(0);

      // 不能取消已完成的订单
      const resp2 = await gqlRaw(
        `mutation { requestCancelTravelTravelOrder(id: "${orderId}") { result { id status } errors { message } } }`
      );
      expect(resp2.data.requestCancelTravelTravelOrder.result).toBeNull();
      expect(resp2.data.requestCancelTravelTravelOrder.errors.length).toBeGreaterThan(0);

      expect(await getOrderStatus(orderId)).toBe('completed');
    });
  });

  test.describe('UI 页面结构验证', () => {
    test('travel_order 列表页加载', async ({ page }) => {
      await page.goto(`${BASE_URL}/pages/travel/travel_order`);
      await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
      await page.waitForTimeout(300);

      await expect(page.locator('[data-phx-main]')).toBeAttached();
    });

    test('travel_order 详情页加载（使用真实数据）', async ({ page }) => {
      const flightOfferId = await ensureFlightOffer();
      const orderId = await createTravelOrder(flightOfferId);

      await page.goto(`${BASE_URL}/pages/travel/travel_order/${orderId}`);
      await page.locator('[data-phx-main]').waitFor({ state: 'attached', timeout: 15000 });
      await page.waitForTimeout(300);

      await expect(page.locator('[data-phx-main]')).toBeAttached();
    });
  });
});
