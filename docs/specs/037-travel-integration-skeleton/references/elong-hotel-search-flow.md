# 艺龙酒店实时搜索流程摘要

来源：

- 原始 HTML：[elong-hotel-search-flow.html](/home/wangbo/document/unibo_ex_poc-feat-37/docs/specs/037-travel-integration-skeleton/references/elong-hotel-search-flow.html)
- 官方页面：`https://open.elong.com/doc/info/cn-main-branch-search?menuName=%E5%AE%9E%E6%97%B6%E6%90%9C%E7%B4%A2%E6%A8%A1%E5%BC%8F`

抓取时间：

- 2026-03-06

更新时间：

- 页面内显示：`2026/01/08 13:48`

## 核心结论

艺龙公开文档把酒店接入拆成了四段：

1. 静态资源
2. 动态查询
3. 交易
4. 订单运营 / 增量同步

这套拆法适合作为 `travel` 的 `hotel adapter` 参考。

## 1. 静态资源

文档描述的接口：

- `hotel.static.city`
- `hotel.static.list`
- `hotel.static.info`

页面原意：

- 先获取城市信息
- 再获取每个城市下酒店
- 再获取酒店明细、房型、图片、设施等
- 周期调用并存储到本地，减少在线查询数据量

对我们模型的启发：

- 这部分更接近 `HotelOffer` 的基础事实来源
- 适合做定时同步，不适合每次下单现场查全量

## 2. 动态查询

文档描述的接口：

- `hotel.rate.min`
- `hotel.detail`

页面原意：

- `hotel.rate.min` 可选，用于列表最小价
- `hotel.detail` 用于获取产品、库存、价格信息

对我们模型的启发：

- 列表价和详情价可以分开
- `HotelOffer` 本地快照不能替代实时详情查询
- 下单前必须再做动态确认

## 3. 交易前校验

文档描述的接口：

- `hotel.data.validate`
- `hotel.data.booking`
- `common.creditcard.validate`

页面原意：

- 创建订单前要先校验库存、总价等信息
- `hotel.data.validate` 更偏下单前校验
- `hotel.data.booking` 与 `validate` 类似，但还可用于房间数变化后的价格/规则刷新
- 信用卡校验是可选增强能力

对我们模型的启发：

- `TravelOrder` 创建前应保留 quote/validate 阶段
- “点击下单”不等于直接建单
- 数量变化、规则变化、价格变化都可能在预订页再次发生

## 4. 创建订单

文档描述的接口：

- `hotel.order.create`
- `hotel.order.pay`

页面原意：

- 创建订单所需字段来自 `hotel.detail`
- 可以“创建并支付”
- 也可以“只创建订单，后续再支付”

对我们模型的启发：

- `TravelOrder` 里订单创建和支付确认应解耦
- `payment_status` 和 `booking_status` 不应混成一个字段

## 5. 订单运营与状态同步

文档描述的接口：

- `hotel.incr.order`
- `hotel.order.cancel`
- `hotel.order.feedback`
- `hotel.order.detail`
- `hotel.order.promote`
- `hotel.order.related`

页面原意：

- 用 `hotel.incr.order` 更新订单状态
- 用 `hotel.order.cancel` 做取消
- 用 `hotel.order.detail` 查详情
- 可用 `hotel.order.promote` 催确认
- 特定旧订单状态下可查关联订单

对我们模型的启发：

1. 订单状态不能只靠创建时结果
2. 需要主动查单
3. 需要增量同步机制
4. 异步确认订单要有“确认中”状态

## 6. 扩展流程

页面还描述了扩展模式：

- 用静态接口 + 周期抓取接口，把酒店动态信息缓存到本地
- 本地自建搜索，以便与自有酒店整合
- 详情页仍建议通过 `hotel.detail` 实时获取动态信息
- 文档提到详情缓存建议不超过 10 分钟

对我们模型的启发：

- 可以做本地搜索索引
- 但详情和下单前仍要实时查
- 这说明 `catalog snapshot` 和 `booking quote` 必须分层

## 对 `travel` POC 的直接映射

### 对 `HotelOffer`

可映射的 canonical 语义：

- 酒店
- 房型
- 价计划
- 入离店日期
- 价格快照
- 可售状态
- 规则快照

### 对 `TravelOrder`

建议保留的阶段：

- quote / validate
- create order
- payment confirm
- cancel
- query

### 对 `TravelFulfillment`

需要能承接：

- confirmed
- issued / reserved
- completed
- failed

## 设计建议

1. `hotel adapter` 至少要有：
   - static sync
   - detail quote
   - validate / booking
   - create
   - pay
   - cancel
   - order detail
   - incr sync

2. `travel` 侧不要假设供应商一定 webhook 推送
3. 下单后需要：
   - 短期主动查单
   - 长期增量同步

## 一句话

艺龙酒店文档最有价值的不是具体字段，而是它把酒店接入明确拆成了“静态同步 + 实时详情 + 下单前校验 + 建单支付 + 订单增量同步”这几段；这套拆法适合作为 `travel hotel adapter` 的骨架参考。
