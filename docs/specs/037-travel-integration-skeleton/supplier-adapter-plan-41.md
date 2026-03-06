# #41 Hotel Supplier Adapter Prep Plan

## 目标与边界

- 目标：为 `feat/41-real-hotel-supplier-adapter` 先完成可执行准备，明确后续真实供应商接入的接口与语义边界。
- 边界：本阶段不接入真实外部 API，不引入 HTTP client/SDK，不做签名鉴权，不改 canonical model。
- 依赖前提：等待 `#44` / `#40` 基线稳定后，再填充真实 provider 细节。

## 实现清单（Prep-Only）

### 1) 接口面

- [x] 定义统一 `HotelAdapter` behavior：
  - `book/3`：创建供应商订单（下单）
  - `query_booking_status/2`：查询单笔订单状态（轮询）
  - `pull_incremental_updates/2`：按 cursor 拉取增量状态
- [x] 在 `HotelFlow` 增加 adapter 注入点：
  - `:supplier_adapter`（默认 mock）
  - `:supplier_adapter_opts`（透传给 adapter）

### 2) 字段映射

- [x] 保持 canonical -> supplier 请求映射入口唯一：`HotelBookingRequest.from_order/2`
- [x] 明确最小映射字段（本阶段固定）：
  - canonical `order_no` -> supplier `order_no`
  - canonical `hotel_code` -> supplier `supplier_hotel_id`
  - canonical `room_type_code` -> supplier `room_code`
  - canonical `rate_plan_code` -> supplier `rate_plan_code`
  - canonical `traveler_count` -> supplier `guest_count`
  - canonical `contact_name/contact_phone` -> supplier `contact`

### 3) 错误语义

- [x] 统一 adapter 错误返回：`{:error, %{code, retryable?, message, raw}}`
- [x] 本阶段固定错误码集合：
  - `:supplier_rejected`（供应商业务拒绝，不重试）
  - `:timeout`（调用超时，可重试）
  - `:temporary_unavailable`（供应商瞬时不可用，可重试）
  - `:invalid_request`（请求参数非法，不重试）
  - `:unexpected_response`（响应无法解析，可按场景重试）

### 4) 重试与轮询策略

- [x] 提供策略占位模块 `HotelAdapterStrategy`（仅配置，不执行真实调度）：
  - 下单重试：最多 3 次，退避 `200ms/500ms/1000ms`
  - 状态轮询：最多 5 次，间隔 `1000ms`
  - 增量同步：窗口 `60s`，cursor 缺失时全量拉一个窗口
- [x] 真实接入阶段只替换 adapter 实现，不改 flow/测试合同。

## 测试场景（本阶段必须可执行）

- [x] 成功下单：`book/3` 返回 `:confirmed`，flow 进入 `order.booked + fulfillment.confirmed`
- [x] 供应商拒绝：`book/3` 返回 `:supplier_rejected`，flow 返回结构化错误
- [x] 调用超时：`book/3` 返回 `:timeout` 且 `retryable? == true`
- [x] 状态增量同步：`pull_incremental_updates/2` 返回 events + next_cursor，验证增量推进

## 后续真实实现切入点（#44/#40 稳定后）

1. 在 `HotelAdapter` 新增真实实现模块（例如 `HotelElongAdapter`），按同一行为返回标准结构。
2. 将 `supplier_payload/raw` 与 provider request/response 一一落档，保留排障证据。
3. 在不改 `HotelFlow` 合同的前提下接入真实重试器、轮询任务与增量同步任务。
4. 扩展集成测试：加入 provider sandbox 响应样例、幂等与重复通知去重校验。
