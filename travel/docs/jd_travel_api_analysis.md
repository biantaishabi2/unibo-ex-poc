# 商旅 API 对比分析 + UniBO Travel 改动方案

> 日期：2026-03-16
> 关联 Issue：#98
> 参考：京东商旅 API、携程商旅 TMC 平台

## 一、行业参考

### 京东商旅 API 结构

API 文档入口：https://open.jd.com/v2/#/doc/api?apiCateId=201260

```
京东商旅（5 大模块）
├── 商旅企业（企业管理层）
│   ├── 企业员工          batchPostEmployee 批量同步
│   ├── 企业员工证件       batchPostEmployeeIdentity 批量同步
│   ├── 企业部门
│   ├── 企业角色          batchPostRole 角色同步
│   ├── 企业职级
│   ├── 企业账单          postEnterpriseBill 账单查询
│   ├── 出差申请单        postApply 行程同步（4种：飞机/酒店/火车/用车）
│   ├── 出差行中申请单    putProccessApply 通知行中审批流程状态
│   ├── 企业机票订单      getEnterpriseFlightOrder / listEnterpriseFlightOrders
│   ├── 企业火车票订单
│   └── 企业用车订单
├── 商旅机票
│   ├── 航班基本信息
│   ├── 机票产品（可售报价）
│   ├── 机票产品规则      listTmcFlightProductRules（退改规则）
│   ├── 机票订单          postTmcFlightOrder（创建订单）
│   ├── 机票改签单
│   ├── 机票改签产品
│   ├── 航班改签信息      postTmcFlightChangeBase（改签航班查询）
│   ├── 机票退票单
│   ├── 机票退票费用
│   ├── 退票原因字典
│   └── 改签原因字典
├── 商旅酒店
│   ├── 酒店城市信息
│   ├── 酒店集团          listTmcHotelGroups
│   ├── 酒店品牌
│   ├── 酒店基本信息      listTmcHotelBases（酒店起价）
│   ├── 酒店静态信息
│   ├── 酒店设施字典      listTmcHotelFacilityDicts
│   ├── 酒店产品          listTmcHotelRateplans（报价）+ postTmcHotelRateplanValidation（可订检查）
│   ├── 酒店订单          post/get/patchTmcHotelOrder
│   └── 酒店退订单
├── 商旅火车票
│   ├── 火车票车次
│   ├── 火车票经停站      listTrainStations
│   ├── 火车票联系人
│   ├── 火车票账号/密码   12306 账号管理
│   ├── 火车票标准订单    postTrainStandardOrder / batchPatchTrainStandardOrder
│   ├── 火车票改签        postTrainChangeOrder / batchPatchTrainChangeOrder
│   └── 火车票退票        postTrainRefundOrder
└── 商旅用车
    ├── 用车产品          postTmcCarProduct（预估价）
    ├── 用车订单
    └── 用车城市信息
```

**京东的定位**：纯供应链通道。企业管理 API 只是数据同步接口（员工/部门/申请单从企业 OA 同步到京东），不提供审批引擎。企业必须有自己的 OA 系统。

### 携程商旅差旅管控体系

携程比京东多做了一层 — **内置差旅管控**：

#### 差旅标准引擎（差标）

按多维度自动匹配差旅标准：

| 维度 | 示例 |
|------|------|
| 职级 | 高管→公务舱/五星酒店，普通员工→经济舱/三星酒店 |
| 城市等级 | 北上广深→酒店上限 800，二线城市→上限 500 |
| 出行方式 | 机票限舱位折扣（如经济舱 66 折）、酒店限星级 |
| 季节/淡旺季 | 旺季酒店标准上浮 |
| 特殊场景 | 酒店拼房就高、夜间用车、协议酒店优先 |

#### 超标四级处理策略

| 级别 | 策略 | 说明 |
|------|------|------|
| L1 | 禁止预订 | 直接拦截，不允许下单 |
| L2 | 填写原因 | 允许下单但必须填写超标理由 |
| L3 | 触发审批流 | 超标达到阈值，进入审批 |
| L4 | 个人支付差额 | 允许超标，超出部分员工自付 |

#### 三层防护

- **事前**：预订时自动校验差标 + 预算余额
- **事中**：实时监测异常行为（重复订单、行程冲突）
- **事后**：合规审计（虚假发票、未订协议酒店、重复报销）

## 二、UniBO Travel 现有模型

```
Travel 域（11 个实体）
├── 静态主数据（5 个）
│   ├── TravelHotel            酒店
│   ├── TravelRoomType         房型
│   ├── TravelAirline          航司
│   ├── TravelCabinClass       舱位
│   └── TravelStaticCodeMapping 供应商静态码映射
├── 报价/Offer（4 个）
│   ├── FlightOffer            机票报价
│   ├── HotelOffer             酒店报价
│   ├── TrainOffer             火车票报价
│   └── VacationOffer          度假套餐报价
├── 交易（1 个）
│   └── TravelOrder            统一订单（机票/酒店/火车票/度假共用）
└── 履约（1 个）
    └── TravelFulfillment      履约（出票/入住确认/候补）
```

**跨域依赖**：
- HR 域 — Employee、Department、JobPosition（员工/部门/职级）
- Organization 域 — Party、PartyRole、PartyRelationship（组织/个人）
- AuthZ 域 — AuthRole、AuthRoleBinding、FeatureGrant、DataScopeGrant（权限）
- Approvals 域 — ApprovalCategory、ApprovalRequest、Approver（通用审批）
- Payment 域 — Payment（支付）
- Delivery 域 — Shipment（配送/物流）

## 三、差距分析

### 核心流程已对齐

搜索 → 报价 → 下单 → 出票/入住 的核心流程与京东/携程基本一致。

### 需要补充的能力

| 优先级 | 差距 | 说明 |
|--------|------|------|
| P1 | 改签/退票独立建模 | 当前用状态字段，无法支撑改签航班查询、退票费用计算、原因记录 |
| P1 | 差旅管控层（Vertical） | 差标引擎 + 超标策略，携程的核心能力，我们需要在 Approvals 上加一层 |
| P2 | 企业管理两条路 | 自建（用 HR/AuthZ/Approvals）+ OA 集成（对接钉钉/飞书/企微） |
| P3 | 静态主数据补充 | 酒店集团、品牌、设施字典、城市、经停站（按需加字段即可） |
| P3 | 用车品类 | 根据业务需求决定 |

### 不需要改的

| 京东有我们没有 | 为什么不需要 |
|-------------|-----------|
| 酒店集团/品牌/设施字典 | 静态数据，在 TravelHotel 上加字段即可 |
| 城市信息 | 已有 Ecommerce::TravelCity 跨域引用 |
| 可订检查 | 宿主 bridge 的 quote 接口已覆盖 |
| 12306 账号管理 | 供应商侧能力，不在我们的模型范围 |
| 京东的 postApply / putProccessApply | 我们自建审批，不需要同步给外部平台 |

## 四、改动方案

### 新增实体（4 个）

#### TravelChangeOrder（改签单）

```yaml
TravelChangeOrder:
  description: 改签订单
  attributes:
    - name: original_order_id    # → TravelOrder（原订单）
    - name: new_offer_id         # → FlightOffer / TrainOffer（新报价）
    - name: change_reason        # 改签原因
    - name: price_difference     # 差价
    - name: change_fee           # 改签手续费
    - name: status               # [pending, approved, completed, rejected]
```

#### TravelRefundOrder（退票/退订单）

```yaml
TravelRefundOrder:
  description: 退票/退订单
  attributes:
    - name: original_order_id    # → TravelOrder（原订单）
    - name: refund_reason        # 退票/退订原因
    - name: refund_fee           # 退票手续费
    - name: refund_amount        # 实退金额
    - name: status               # [pending, approved, refunded, rejected]
```

#### TravelPolicy（差旅标准政策）

```yaml
TravelPolicy:
  description: 差旅标准（按职级×城市×品类匹配差标）
  attributes:
    - name: policy_name          # "总部差旅标准" / "分公司标准"
    - name: product_type         # flight / hotel / train / car
    - name: employee_level       # 职级（关联 HR::JobPosition）
    - name: city_tier            # 城市等级（一线/二线/三线）
    - name: season               # 淡旺季标识（可选）
    - name: max_amount           # 金额上限
    - name: cabin_class_limit    # 舱位限制（经济舱/公务舱）
    - name: hotel_star_limit     # 酒店星级限制
    - name: exceed_strategy      # block / require_reason / require_approval / personal_pay
    - name: personal_pay_ratio   # 个人支付比例
  relationships:
    - enterprise → Organization::Party
```

#### TravelPolicyCheck（差标校验记录）

```yaml
TravelPolicyCheck:
  description: 订单级差标校验结果
  attributes:
    - name: check_result         # compliant / exceeded / blocked
    - name: policy_amount        # 差标金额
    - name: actual_amount        # 实际金额
    - name: exceed_amount        # 超标金额
    - name: exceed_ratio         # 超标比例
    - name: exceed_strategy      # 命中的超标策略
    - name: exceed_reason        # 超标原因（员工填写）
    - name: personal_pay_amount  # 个人支付部分
  relationships:
    - order → TravelOrder
    - policy → TravelPolicy
    - approval_request → Approvals::ApprovalRequest
```

### 改动后的实体目录

```
Travel 域（15 个实体，新增 4 个）
├── 静态主数据（5 个）— 不变
│   ├── TravelHotel
│   ├── TravelRoomType
│   ├── TravelAirline
│   ├── TravelCabinClass
│   └── TravelStaticCodeMapping
├── 报价/Offer（4 个）— 不变
│   ├── FlightOffer
│   ├── HotelOffer
│   ├── TrainOffer
│   └── VacationOffer
├── 交易（3 个）— 新增 2 个
│   ├── TravelOrder            统一订单
│   ├── TravelChangeOrder      ← 新增：改签单
│   └── TravelRefundOrder      ← 新增：退票/退订单
├── 履约（1 个）— 不变
│   └── TravelFulfillment
└── 差旅管控（2 个）— 新增
    ├── TravelPolicy           ← 新增：差旅标准政策
    └── TravelPolicyCheck      ← 新增：差标校验记录
```

### 差标校验流程

```
员工选择航班/酒店
  ↓
TravelPolicy 引擎匹配差标（职级+城市+品类）
  ↓
├── 合规 → 直接下单
├── 超标 + block → 拦截，不允许下单
├── 超标 + require_reason → 填写原因后下单
├── 超标 + require_approval → 创建 ApprovalRequest → 审批通过后下单
└── 超标 + personal_pay → 计算差额 → 企业付标准内 + 员工付超出部分
```

## 五、企业管理两条路

### 路线 A：自建（企业没有 OA）

用我们的 HR + Organization + AuthZ + Approvals 域，零集成：

| 功能 | 域 | 实体 |
|------|-----|------|
| 员工管理 | HR | Employee、EmploymentContract |
| 部门管理 | HR | Department |
| 职级管理 | HR | JobPosition、PayGrade |
| 角色权限 | AuthZ | AuthRole、AuthRoleBinding、FeatureGrant、DataScopeGrant |
| 审批流程 | Approvals | ApprovalCategory、ApprovalRequest、Approver |

### 路线 B：OA 集成（企业有钉钉/飞书/企微）

新增 `TravelApprovalBridge`（类似 `TravelHost.ShopBridgeClient`）：

```
POST /api/travel/approval_webhook/submit    ← 推送审批请求到企业 OA
POST /api/travel/approval_webhook/callback  ← 企业 OA 回调审批结果
```

人员数据从 OA 自动同步，审批在 OA 侧完成后回调我们。

### 管理端配置开关

```
差旅审批模式：
  ○ 自建模式 → 显示员工/部门/职级/角色/审批管理菜单
  ● OA 集成模式 → 显示 OA 配置 + 同步日志菜单
```

## 六、前端页面完整清单（66 个）

### 用户端（24 个）

| # | 页面 | 状态 | 关联实体 |
|---|------|------|---------|
| 1 | 首页（机票/酒店/火车票 tab） | ✅ 现有 | — |
| 2 | 机票搜索结果 | ✅ 现有 | FlightOffer |
| 3 | 机票航班详情 | ✅ 现有 | FlightOffer |
| 4 | 机票预订 | ✅ 现有 | TravelOrder |
| 5 | 酒店搜索结果 | ✅ 现有 | HotelOffer |
| 6 | 酒店详情 | ✅ 现有 | HotelOffer |
| 7 | 酒店预订 | ✅ 现有 | TravelOrder |
| 8 | 火车票搜索结果 | ✅ 现有 | TrainOffer |
| 9 | 火车票详情 | ✅ 现有 | TrainOffer |
| 10 | 火车票预订 | ✅ 现有 | TravelOrder |
| 11 | 预订确认 | ✅ 现有 | TravelOrder |
| 12 | 支付确认 | ✅ 现有 | Payment |
| 13 | 订单列表 | ✅ 现有 | TravelOrder |
| 14 | 订单详情 | ✅ 现有 | TravelOrder |
| 15 | 出行人管理 | ✅ 现有 | — |
| 16 | 改签航班/车次选择 | 🆕 新增 | TravelChangeOrder + Offer |
| 17 | 改签确认 | 🆕 新增 | TravelChangeOrder |
| 18 | 退票申请 | 🆕 新增 | TravelRefundOrder |
| 19 | 退票结果 | 🆕 新增 | TravelRefundOrder |
| 20 | 出差申请 | 🆕 新增 | Approvals::ApprovalRequest |
| 21 | 超标审批详情 | 🆕 新增 | TravelPolicyCheck + ApprovalRequest |
| 22 | 个人中心 | 🆕 新增 | HR::Employee + PersonProfile |
| 23 | 我的审批 | 🆕 新增 | Approvals::ApprovalRequest |
| 24 | 审批详情 | 🆕 新增 | ApprovalRequest + Approver |

### 管理端（42 个）

| # | 页面 | 状态 | 关联实体 |
|---|------|------|---------|
| 1-2 | 航班报价 列表/详情 | ✅ 现有 | FlightOffer |
| 3-4 | 酒店报价 列表/详情 | ✅ 现有 | HotelOffer |
| 5-6 | 火车票报价 列表/详情 | ✅ 现有 | TrainOffer |
| 7-8 | 度假套餐 列表/详情 | ✅ 现有 | VacationOffer |
| 9-10 | 订单管理 列表/详情 | ✅ 现有 | TravelOrder |
| 11-12 | 履约管理 列表/详情 | ✅ 现有 | TravelFulfillment |
| 13-14 | 航司管理 列表/详情 | ✅ 现有 | TravelAirline |
| 15-16 | 酒店管理 列表/详情 | ✅ 现有 | TravelHotel |
| 17-18 | 舱位管理 列表/详情 | ✅ 现有 | TravelCabinClass |
| 19-20 | 房型管理 列表/详情 | ✅ 现有 | TravelRoomType |
| 21-22 | 静态码映射 列表/详情 | ✅ 现有 | TravelStaticCodeMapping |
| 23-24 | 差旅政策 列表/详情 | 🆕 新增 | TravelPolicy |
| 25-26 | 改签单 列表/详情 | 🆕 新增 | TravelChangeOrder |
| 27-28 | 退票单 列表/详情 | 🆕 新增 | TravelRefundOrder |
| 29-30 | 差标校验 列表/详情 | 🆕 新增 | TravelPolicyCheck |
| 31 | 企业信息 | 🆕 新增 | Organization::Party |
| 32-33 | 部门管理 列表/详情 | 🆕 新增 | HR::Department |
| 34-35 | 员工管理 列表/详情 | 🆕 新增 | HR::Employee |
| 36-37 | 职级管理 列表/详情 | 🆕 新增 | HR::JobPosition |
| 38-39 | 角色权限 列表/详情 | 🆕 新增 | AuthZ::AuthRole |
| 40 | 审批规则配置 | 🆕 新增 | Approvals::ApprovalCategory |
| 41 | OA 集成配置 | 🆕 新增 | TravelApprovalBridge |
| 42 | OA 同步日志 | 🆕 新增 | 同步记录 |

## 七、与京东/携程的定位对比

| 维度 | 京东商旅 | 携程商旅 | UniBO Travel |
|------|---------|---------|-------------|
| 供应链通道 | ✅ | ✅ | ✅（ShopBridge 多供应商适配） |
| 内置审批 | ❌（要求外部 OA） | ✅ | ✅（Approvals 域） |
| 差标引擎 | ❌ | ✅ | ✅（TravelPolicy，需新增） |
| 超标策略 | ❌ | ✅（四级） | ✅（四级，需新增） |
| OA 集成 | ✅（仅此一条路） | ✅（可选） | ✅（可选，两条路） |
| 企业管理 | ✅（同步接口） | ✅ | ✅（HR + AuthZ，自建） |
| 改签/退票 | ✅（独立资源） | ✅ | 🔧 需独立建模 |
| 用车 | ✅ | ✅ | ❌ 暂无 |
| 合规审计 | ❌ | ✅（12 类模型） | 🔧 TravelPolicyCheck 可支撑 |

**我们的优势**：审批内置 + 供应商多通道 + 两条路（自建/OA 集成）+ 平台化（两周交付 vs 半年自建）

Sources:
- [京东商旅 API 文档](https://open.jd.com/v2/#/doc/api?apiCateId=201260)
- [携程商旅：赋能财务人员的差旅管理全流程解决方案](https://ct.ctrip.com/thinktanks/204774649348578)
- [智能差旅审批系统推荐](https://ct.ctrip.com/thinktanks/174313146442253)
- [携程商旅差旅费控系统深度评测](https://ct.ctrip.com/thinktanks/143930990776810)
- [预订与审批_差旅_携程商旅](https://ct.ctrip.com/faqs/booking-and-approval)
