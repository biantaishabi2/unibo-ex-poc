# Travel Supplier Reference

## Purpose

这份文档只做 `travel` POC 的供应商参考，不作为 canonical model 的真相源。

用途只有两个：

1. 帮 `hotel` adapter 定接口分层
2. 帮后续 `flight / train / vacation` adapter 对齐“静态资源 / 动态报价 / 交易 / 履约”四段结构

## Current Decision

- `travel` 先定自己的 canonical model
- 供应商差异留在 adapter 层
- 公开供应商文档只作为参考，不直接决定 `HotelOffer / TravelOrder / TravelFulfillment` 命名

## Elong Hotel API As Reference

当前最适合参考的是同程艺龙公开酒店接口。

公开资料显示它的链路基本分成四层：

1. 静态资源
   - `hotel.static.city`
   - `hotel.list`
   - `hotel.info`

2. 动态查询
   - `hotel.rate.min`
   - `hotel.detail`

3. 交易
   - `hotel.data.validate`
   - `hotel.data.booking`
   - `hotel.order.create`
   - `hotel.order.pay`
   - `hotel.order.cancel`
   - `hotel.order.detail`

4. 增量同步
   - `hotel.incr.order`

这对 `travel` POC 的直接启发是：

- 静态供给和动态报价必须分开
- 下单前应保留 validate / booking 这类预检查语义
- 订单创建、支付、取消、查单应分步
- 后续真实 adapter 需要考虑增量订单状态同步

## Mapping Guidance

### HotelOffer

适合从供应商侧映射进 `HotelOffer` 的，是这类业务语义：

- 酒店
- 房型
- 价计划
- 入离店日期
- 价格快照
- 可售状态
- 预订规则

不直接进 canonical 命名的，是这类供应商特有字段：

- 原始酒店 ID
- 原始房型 ID
- 原始价计划 ID
- 原始状态码
- 原始请求/响应报文

这些留在 adapter 层或原始 payload 存档。

### TravelOrder

供应商侧的：

- validate
- booking
- create order
- cancel order
- query order

应映射为我们自己的统一订单语义，不直接复用供应商 action 名。

### TravelFulfillment

供应商侧确认、发券、完成、失败等状态，应映射进统一履约状态。

## Boundary

这份参考文档不解决：

- 宿主 `shop` 的 `context / quote / payment`
- supplier 真实联调参数
- 鉴权签名细节
- 供应商字段一比一落库方案

这些属于后续 `supplier adapter` 实现阶段。

## Sources

- Elong Open Platform: `https://open.elong.com/home/index`
- Elong hotel search flow: `https://open.elong.com/doc/info/cn-main-branch-search?menuName=%E5%AE%9E%E6%97%B6%E6%90%9C%E7%B4%A2%E6%A8%A1%E5%BC%8F`

## Recommendation

POC 下一步如果做真实 hotel adapter，可以先按这条结构落：

1. static sync
2. quote / validate
3. booking / create order
4. cancel / query
5. incremental sync

一句话：

同程艺龙公开酒店接口适合作为 `hotel adapter` 的分层参考，但不应该直接变成 `travel` 的 canonical model。
