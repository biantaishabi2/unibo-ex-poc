/**
 * TravelOrder 状态机 action E2E 测试（GraphQL 后端回归测试）
 *
 * TravelOrder 创建参数复杂（依赖 FlightOffer + 占位 customerId），
 * 且详情页 action 按钮在当前 PageHostLive 动态编译下同样不渲染。
 * 因此本文件仅做 GraphQL mutation 驱动的后端回归测试。
 *
 * 覆盖：
 * - 主流程：draft -> quoted -> submitted -> booking_pending -> booked -> completed
 * - 取消流程：booked -> cancel_pending -> cancelled
 * - 失败流程：submitted -> failed
 * - 改签流程：booked -> request_change(pending) -> confirm_change(changed)
 * - 非法状态流转拒绝
 */
import { test, expect } from '@playwright/test';

const BASE_URL = 'http://localhost:4100';
const GRAPHQL_URL = `${BASE_URL}/api/graphql`;
const TENANT_ID = '00000000-0000-0000-0000-000000000001';
const FAKE_CUSTOMER_ID = '00000000-0000-0000-0000-000000000099';

// ── GraphQL 辅助 ──

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

async function getOrderStatus(id: string): Promise<string> {
  const data = await gql(`
    query { getTravelTravelOrder(id: "${id}") { id status } }
  `);
  return data.getTravelTravelOrder.status;
}

async function getOrderFullStatus(id: string): Promise<{ status: string; changeStatus: string }> {
  const data = await gql(`
    query { getTravelTravelOrder(id: "${id}") { id status changeStatus } }
  `);
  return data.getTravelTravelOrder;
}

// 状态流转 mutation
async function confirmQuote(id: string): Promise<string> {
  const data = await gql(`mutation { confirmQuoteTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`);
  return data.confirmQuoteTravelTravelOrder.result.status;
}

async function submitOrder(id: string): Promise<string> {
  const data = await gql(`mutation { submitOrderTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`);
  return data.submitOrderTravelTravelOrder.result.status;
}

async function markPaymentSucceeded(id: string): Promise<string> {
  const data = await gql(`mutation { markPaymentSucceededTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`);
  return data.markPaymentSucceededTravelTravelOrder.result.status;
}

async function markBooked(id: string): Promise<string> {
  const data = await gql(`mutation { markBookedTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`);
  return data.markBookedTravelTravelOrder.result.status;
}

async function markCompleted(id: string): Promise<string> {
  const data = await gql(`mutation { markCompletedTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`);
  return data.markCompletedTravelTravelOrder.result.status;
}

async function requestCancel(id: string): Promise<string> {
  const data = await gql(`mutation { requestCancelTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`);
  return data.requestCancelTravelTravelOrder.result.status;
}

async function executeCancel(id: string): Promise<string> {
  const data = await gql(`mutation { executeCancelTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`);
  return data.executeCancelTravelTravelOrder.result.status;
}

async function markOrderFailed(id: string): Promise<string> {
  const data = await gql(`mutation { markOrderFailedTravelTravelOrder(id: "${id}") { result { id status } errors { message } } }`);
  return data.markOrderFailedTravelTravelOrder.result.status;
}

async function requestChange(id: string): Promise<string> {
  const data = await gql(`mutation { requestChangeTravelTravelOrder(id: "${id}", input: { originalOrderRef: "ORIG-001" }) { result { id status changeStatus } errors { message } } }`);
  return data.requestChangeTravelTravelOrder.result.changeStatus;
}

async function confirmChange(id: string): Promise<string> {
  const data = await gql(`mutation { confirmChangeTravelTravelOrder(id: "${id}") { result { id status changeStatus } errors { message } } }`);
  return data.confirmChangeTravelTravelOrder.result.changeStatus;
}

// 共享 FlightOffer
let sharedFlightOfferId: string | null = null;
async function ensureFlightOffer(): Promise<string> {
  if (!sharedFlightOfferId) {
    sharedFlightOfferId = await createFlightOffer();
  }
  return sharedFlightOfferId;
}

// ── 测试用例 ──

test.describe('TravelOrder 状态机 — GraphQL 后端回归', () => {

  test('主流程：draft -> quoted -> submitted -> booking_pending -> booked -> completed', async () => {
    const flightOfferId = await ensureFlightOffer();
    const orderId = await createTravelOrder(flightOfferId);

    expect(await getOrderStatus(orderId)).toBe('draft');

    expect(await confirmQuote(orderId)).toBe('quoted');
    expect(await getOrderStatus(orderId)).toBe('quoted');

    expect(await submitOrder(orderId)).toBe('submitted');
    expect(await getOrderStatus(orderId)).toBe('submitted');

    expect(await markPaymentSucceeded(orderId)).toBe('booking_pending');
    expect(await getOrderStatus(orderId)).toBe('booking_pending');

    expect(await markBooked(orderId)).toBe('booked');
    expect(await getOrderStatus(orderId)).toBe('booked');

    expect(await markCompleted(orderId)).toBe('completed');
    expect(await getOrderStatus(orderId)).toBe('completed');
  });

  test('取消流程：booked -> cancel_pending -> cancelled', async () => {
    const flightOfferId = await ensureFlightOffer();
    const orderId = await createTravelOrder(flightOfferId);

    await confirmQuote(orderId);
    await submitOrder(orderId);
    await markPaymentSucceeded(orderId);
    await markBooked(orderId);

    expect(await requestCancel(orderId)).toBe('cancel_pending');
    expect(await getOrderStatus(orderId)).toBe('cancel_pending');

    expect(await executeCancel(orderId)).toBe('cancelled');
    expect(await getOrderStatus(orderId)).toBe('cancelled');
  });

  test('失败流程：submitted -> failed', async () => {
    const flightOfferId = await ensureFlightOffer();
    const orderId = await createTravelOrder(flightOfferId);

    await confirmQuote(orderId);
    await submitOrder(orderId);

    expect(await markOrderFailed(orderId)).toBe('failed');
    expect(await getOrderStatus(orderId)).toBe('failed');
  });

  test('改签流程：booked -> request_change(pending) -> confirm_change(changed)', async () => {
    const flightOfferId = await ensureFlightOffer();
    const orderId = await createTravelOrder(flightOfferId);

    await confirmQuote(orderId);
    await submitOrder(orderId);
    await markPaymentSucceeded(orderId);
    await markBooked(orderId);

    expect(await requestChange(orderId)).toBe('pending');
    expect(await confirmChange(orderId)).toBe('changed');

    const fullStatus = await getOrderFullStatus(orderId);
    expect(fullStatus.status).toBe('booked');
    expect(fullStatus.changeStatus).toBe('changed');
  });

  test('非法流转拒绝：draft 不能直接 submit_order', async () => {
    const flightOfferId = await ensureFlightOffer();
    const orderId = await createTravelOrder(flightOfferId);

    const resp = await gqlRaw(
      `mutation { submitOrderTravelTravelOrder(id: "${orderId}") { result { id status } errors { message } } }`
    );
    const result = resp.data.submitOrderTravelTravelOrder;
    expect(result.result).toBeNull();
    expect(result.errors.length).toBeGreaterThan(0);
    expect(await getOrderStatus(orderId)).toBe('draft');
  });

  test('非法流转拒绝：completed 订单不能再操作', async () => {
    const flightOfferId = await ensureFlightOffer();
    const orderId = await createTravelOrder(flightOfferId);

    await confirmQuote(orderId);
    await submitOrder(orderId);
    await markPaymentSucceeded(orderId);
    await markBooked(orderId);
    await markCompleted(orderId);

    const resp = await gqlRaw(
      `mutation { requestCancelTravelTravelOrder(id: "${orderId}") { result { id status } errors { message } } }`
    );
    expect(resp.data.requestCancelTravelTravelOrder.result).toBeNull();
    expect(resp.data.requestCancelTravelTravelOrder.errors.length).toBeGreaterThan(0);
    expect(await getOrderStatus(orderId)).toBe('completed');
  });
});
