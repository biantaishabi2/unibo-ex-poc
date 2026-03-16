# 京东商旅 API 结构 vs UniBO Travel 模型对比分析

> 日期：2026-03-16
> API 文档入口：https://open.jd.com/v2/#/doc/api?apiCateId=201260
> 关联 Issue：#98

## 一、京东商旅 API 总览

京东商家开放平台（酒旅频道）覆盖 **5 大模块**：

| 模块 | 品类 | API 数量 |
|------|------|---------|
| 商旅企业 | 企业管理（员工/部门/角色/职级/账单/审批） | 10+ |
| 商旅机票 | 航班查询/下单/改签/退票 | 12 |
| 商旅酒店 | 酒店查询/报价/下单/退订 | 10 |
| 商旅火车票 | 车次查询/下单/改签/退票 | 8 |
| 商旅用车 | 预估价/下单/城市 | 3 |

## 二、机票模块详细对比

### 京东机票 API

```
商旅机票
├── 航班基本信息        ← 航班查询
├── 机票产品            ← 可售报价（航班+舱位+价格）
├── 机票产品规则        ← listTmcFlightProductRules（退改规则）
├── 机票订单            ← postTmcFlightOrder（创建订单）
├── 机票改签单          ← 改签订单 CRUD
├── 机票改签产品        ← 改签可选航班报价
├── 航班改签信息        ← postTmcFlightChangeBase（改签航班查询）
├── 机票退票单          ← 退票订单 CRUD
├── 机票退票费用        ← 退票费用计算
├── 退票原因字典        ← 退票原因枚举
└── 改签原因字典        ← 改签原因枚举
```

### UniBO Travel 机票模型

```
Travel 域
├── FlightOffer          ← 航班+报价+退改规则（合并）
├── TravelOrder          ← 订单（含改签/退票状态字段）
├── TravelFulfillment    ← 履约（出票/候补）
├── TravelAirline        ← 航司主数据
├── TravelCabinClass     ← 舱位主数据
└── TravelStaticCodeMapping ← 供应商静态码映射
```

### 差异点

| 维度 | 京东 | UniBO | 差距 |
|------|------|-------|------|
| 改签 | 独立资源：改签单 + 改签产品 + 改签航班查询 + 改签原因字典 | TravelOrder.change_status 状态字段 | 需独立建模 |
| 退票 | 独立资源：退票单 + 退票费用 + 退票原因字典 | TravelOrder 工作流转换 | 需独立建模 |
| 退改规则 | 独立 API：listTmcFlightProductRules | FlightOffer.refund_change_policy 文本字段 | 需结构化 |
| 航班信息 | 独立 API | FlightOffer 内嵌字段 | 可接受 |

## 三、酒店模块详细对比

### 京东酒店 API

```
商旅酒店
├── 酒店城市信息        ← 城市查询
├── 酒店集团            ← listTmcHotelGroups
├── 酒店品牌            ← 品牌查询
├── 酒店基本信息        ← listTmcHotelBases（酒店起价）
├── 酒店静态信息        ← 酒店详情
├── 酒店设施字典        ← listTmcHotelFacilityDicts
├── 酒店产品
│   ├── listTmcHotelRateplans     ← 报价查询
│   └── postTmcHotelRateplanValidation ← 可订检查
├── 酒店订单
│   ├── postTmcHotelOrder         ← 创建订单
│   ├── getTmcHotelOrder          ← 查询详情
│   └── patchTmcHotelOrder        ← 取消/支付
└── 酒店退订单          ← 退订管理
```

### UniBO Travel 酒店模型

```
├── HotelOffer           ← 酒店报价（合并）
├── TravelHotel          ← 酒店主数据
├── TravelRoomType       ← 房型主数据
└── TravelOrder          ← 订单（共用）
```

### 差异点

| 维度 | 京东 | UniBO | 差距 |
|------|------|-------|------|
| 酒店集团/品牌 | 独立 API | 无 | 缺主数据 |
| 设施字典 | 独立 API | 无 | 缺字典 |
| 城市信息 | 独立 API | 无 | 内嵌在搜索 |
| 可订检查 | postTmcHotelRateplanValidation | 无 | 缺验证步骤 |
| 退订 | 独立资源 | TravelOrder 状态 | 同改签/退票 |

## 四、火车票模块详细对比

### 京东火车票 API

```
商旅火车票
├── 火车票车次          ← 车次查询
├── 火车票经停站        ← listTrainStations
├── 火车票联系人        ← 联系人管理
├── 火车票账号/密码     ← 12306 账号管理
├── 火车票标准订单
│   ├── postTrainStandardOrder        ← 预定下单
│   └── batchPatchTrainStandardOrder  ← 出票/取消
├── 火车票改签
│   ├── postTrainChangeOrder          ← 创建改签
│   └── batchPatchTrainChangeOrder    ← 确认改签
└── 火车票退票
    └── postTrainRefundOrder          ← 申请退票
```

### UniBO Travel 火车票模型

```
├── TrainOffer           ← 车次报价
└── TravelOrder          ← 订单（共用）
```

### 差异点

| 维度 | 京东 | UniBO | 差距 |
|------|------|-------|------|
| 经停站 | 独立 API | 无 | 缺主数据 |
| 12306 账号 | 独立管理 | 无 | 缺账号管理 |
| 改签/退票 | 独立接口 | 状态字段 | 同机票 |
| 出票/取消 | batchPatch 批量操作 | 工作流转换 | 可接受 |

## 五、企业管理层对比

### 京东企业管理 API

```
商旅企业
├── 企业员工            ← 员工 CRUD
├── 企业部门            ← 部门 CRUD
├── 企业角色            ← 角色 CRUD
├── 企业职级            ← 职级 CRUD
├── 企业账单            ← 账单查询
├── 出差申请单          ← 差旅审批（出发前）
├── 出差行中申请单      ← 行中补单审批
├── 企业机票订单        ← 企业维度订单查询
├── 企业火车票订单      ← 企业维度订单查询
└── 企业用车订单        ← 企业维度订单查询
```

### UniBO 对应

| 京东 | UniBO | 位置 |
|------|-------|------|
| 企业员工/部门/角色 | Sales::Customer + Organization | Sales 域 |
| 出差申请单 | **无** | 需新增 |
| 出差行中申请单 | **无** | 需新增 |
| 企业账单 | Payment::Payment | Payment 域 |
| 企业维度订单查询 | TravelOrder（按 host_enterprise_id 筛选） | Travel 域 |

## 六、核心结论

### 已对齐的能力

- 核心下单流程：搜索 → 报价 → 下单 → 出票 ✅
- 多品类支持：机票 + 酒店 + 火车票 ✅
- 供应商适配层：TravelStaticCodeMapping + ShopBridge ✅
- 履约管理：TravelFulfillment ✅

### 需要补充的能力（按优先级）

#### P1 — 改签/退票独立建模

当前用状态字段，无法支撑：
- 改签航班查询（需要查新航班报价）
- 退票费用计算（需要独立计算逻辑）
- 改签/退票原因记录

建议新增：
- `TravelChangeOrder`（改签单）
- `TravelRefundOrder`（退票/退订单）
- `TravelChangeReason` / `TravelRefundReason`（原因字典）

#### P2 — 企业差旅审批链

缺少出差申请 → 审批 → 预订 → 报销的完整链路。

建议新增：
- `TravelRequest`（出差申请单）
- `TravelPolicy`（差旅政策：标准/超标/审批规则）

#### P2 — 主数据管理独立化

酒店集团、品牌、设施字典、城市信息、经停站等需要独立管理。

当前已有：TravelAirline、TravelHotel、TravelCabinClass、TravelRoomType
需补充：TravelCity、HotelGroup、HotelBrand、HotelFacility、TrainStation

#### P3 — 可订检查

下单前增加库存/价格验证步骤，避免下单失败。
可在宿主 bridge 的 quote 接口中实现。

#### P3 — 用车品类

根据业务需求决定是否补充 CarOffer + CarOrder。

## 七、与我们之前参考的供应商对比

从 mock 数据中的 `SUP_CTRIP`（携程）、`SUP_QUNAR`（去哪儿）可以看出，我们之前主要参考的是 OTA 供应商接口。

| 维度 | OTA（携程/去哪儿） | TMC（京东商旅） | 我们 |
|------|-------------------|----------------|------|
| 定位 | 面向 C 端消费者 | 面向 B 端企业 | B 端 + 宿主模式 |
| 企业管理 | 无 | 完整（员工/部门/审批） | 部分（Customer/Organization） |
| 差旅政策 | 无 | 有（超标提示/审批） | 有超标提示，无审批链 |
| 改签/退票 | 简单（状态变更） | 完整（独立资源） | 简单（状态字段） |
| 用车 | 有（携程用车） | 有 | 无 |

京东商旅是典型的 TMC（Travel Management Company）模式，比 OTA 多了企业管理和差旅合规层。我们的架构更接近 TMC 但缺少审批链和改签/退票的独立建模。
