# 模型业务说明

- 版本：1.0
- 领域：Travel
- 领域说明：Travel vertical canonical model，作为电商域 overlay，通过 target_domain 引用 Sales/Payment/Delivery 域实体
- 实体数量：11

## 实体：TravelHotel（聚合根）

- 说明：酒店主数据（Travel 层，来源 OFBiz Product）
- 来源：基于 产品；来源域 ofbiz/product；过滤条件 产品类型编号=TRAVEL_HOTEL

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 酒店规范编码（hotel_code）：文本（必填）
- 酒店名称（hotel_name）：文本（必填）
- 城市编码：文本，说明 城市编码冗余（便于兼容检索）
- 酒店星级（hotel_star）：文本
- 状态：枚举，默认值 启用，可选值：启用 / 停用

#### 关系
- 城市：多对一 -> TravelCity，外键 城市编号

#### 唯一约束
- 唯一约束 unique_hotel_code：hotel_code

### Conduct（行为声明）

#### 操作
- 创建，可写字段：hotel_code、hotel_name、城市编号、城市编码、hotel_star、状态
- 查询
- 更新，可写字段：hotel_name、城市编号、城市编码、hotel_star、状态

#### 变更
- 在 创建 / 更新 时，将 编号 设为 编号

## 实体：TravelRoomType（聚合根）

- 说明：酒店房型主数据（Travel 层，来源 OFBiz ProductFeature）
- 来源：基于 产品功能；来源域 ofbiz/product；过滤条件 产品功能类型编号=ROOM_TYPE

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 房型规范编码（room_type_code）：文本（必填）
- 房型名称（room_type_name）：文本（必填）
- 酒店编码冗余（便于兼容检索）（hotel_code）：文本
- 床型（bed_type）：文本
- 状态：枚举，默认值 启用，可选值：启用 / 停用

#### 关系
- hotel：多对一 -> TravelHotel，外键 hotel_id

#### 唯一约束
- 唯一约束 unique_room_type_code：room_type_code

### Conduct（行为声明）

#### 操作
- 创建，可写字段：room_type_code、room_type_name、hotel_id、hotel_code、bed_type、状态
- 查询
- 更新，可写字段：room_type_name、hotel_id、hotel_code、bed_type、状态

#### 变更
- 在 创建 / 更新 时，将 编号 设为 编号

## 实体：TravelAirline（聚合根）

- 说明：航司主数据（Travel 层，来源 OFBiz PartyGroup）
- 来源：基于 参与方分组；来源域 ofbiz/party；过滤条件 industry=AIRLINE

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 航司规范编码（airline_code）：文本（必填）
- 航司名称（airline_name）：文本（必填）
- IATA 二字码（iata_code）：文本
- ICAO 三字码（icao_code）：文本
- 状态：枚举，默认值 启用，可选值：启用 / 停用

#### 唯一约束
- 唯一约束 unique_airline_code：airline_code

### Conduct（行为声明）

#### 操作
- 创建，可写字段：airline_code、airline_name、iata_code、icao_code、状态
- 查询
- 更新，可写字段：airline_name、iata_code、icao_code、状态

#### 变更
- 在 创建 / 更新 时，将 编号 设为 编号

## 实体：TravelCabinClass（聚合根）

- 说明：舱位主数据（Travel 层，来源 OFBiz Enumeration）
- 来源：基于 枚举；来源域 ofbiz/common；过滤条件 枚举类型编号=CABIN_CLASS

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 舱位规范编码（cabin_class_code）：文本（必填）
- 舱位名称（cabin_class_name）：文本（必填）
- 舱位等级序（cabin_rank）：整数
- 状态：枚举，默认值 启用，可选值：启用 / 停用

#### 唯一约束
- 唯一约束 unique_cabin_class_code：cabin_class_code

### Conduct（行为声明）

#### 操作
- 创建，可写字段：cabin_class_code、cabin_class_name、cabin_rank、状态
- 查询
- 更新，可写字段：cabin_class_name、cabin_rank、状态

#### 变更
- 在 创建 / 更新 时，将 编号 设为 编号

## 实体：TravelStaticCodeMapping（聚合根）

- 说明：供应商静态码到 Travel 主数据的映射（Travel 层统一适配）
- 来源：基于 数据来源；来源域 ofbiz/common

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 供应商编码：文本（必填），说明 供应商编码
- 主数据对象类型（object_type）：枚举（必填），可选值：城市 / airport / station / hotel / room_type / airline / cabin_class
- Travel 实体名（canonical_entity）：文本（必填）
- 规范编号：唯一标识（必填），说明 Travel 实体 ID
- 外部编码：文本（必填），说明 供应商侧编码
- 外部名称：文本，说明 供应商侧名称
- 状态：枚举，默认值 启用，可选值：启用 / 停用

#### 唯一约束
- 唯一约束 unique_supplier_static_code：供应商编码、object_type、外部编码

### Conduct（行为声明）

#### 操作
- 创建，可写字段：供应商编码、object_type、canonical_entity、规范编号、外部编码、外部名称、状态
- 查询
- 更新，可写字段：canonical_entity、规范编号、外部名称、状态

#### 变更
- 在 创建 / 更新 时，将 编号 设为 编号

## 实体：HotelOffer（聚合根）

- 说明：酒店可售 offer，承载房型、价计划、价态和可售规则快照

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 租户编号：唯一标识（必填），说明 租户 ID
- 宿主商城 ID，仅用于宿主侧隔离和桥接上下文（host_shop_id）：唯一标识
- 供应商编码：文本（必填），说明 供应商编码
- 酒店编码（hotel_code）：文本（必填）
- 酒店名称（hotel_name）：文本（必填）
- 城市编码：文本（必填），说明 城市编码
- 房型编码（room_type_code）：文本（必填）
- 费率计划编码：文本（必填），说明 价计划编码
- 入住日期（checkin_date）：日期（必填）
- 结账日期：日期（必填），说明 离店日期
- 对客展示价快照（listed_price）：金额（必填），必须 ≥ 0（listed_price 不能为负数）
- 结算价格：金额，必须 ≥ 0（settlement_price 不能为负数），说明 结算价快照
- 币种：文本，默认值 CNY，说明 币种
- 库存数量：整数，默认值 0，必须 ≥ 0（inventory_count 不能为负数），说明 可售库存快照
- 取消规则快照（cancellation_policy）：长文本
- 担保规则快照（guarantee_policy）：长文本
- 销售状态：枚举，默认值 草稿，可选值：草稿 / 启用 / 停用 / 已过期，说明 可售状态
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 城市参考：多对一 -> TravelCity，外键 城市参考编号
- hotel_ref：多对一 -> TravelHotel，外键 hotel_ref_id
- room_type_ref：多对一 -> TravelRoomType，外键 room_type_ref_id
- 订单：一对多 -> TravelOrder，外键 hotel_offer_id

#### 唯一约束
- 唯一约束 unique_hotel_offer_snapshot：租户编号、供应商编码、hotel_code、room_type_code、费率计划编码、checkin_date、结账日期

### Conduct（行为声明）

#### 操作
- 创建，可写字段：租户编号、host_shop_id、供应商编码、hotel_code、hotel_ref_id、hotel_name、城市编码、城市参考编号、room_type_code、room_type_ref_id、费率计划编码、checkin_date、结账日期、listed_price、结算价格、币种、库存数量、cancellation_policy、guarantee_policy、销售状态
- 查询
- 更新，可写字段：hotel_name、城市编码、城市参考编号、hotel_ref_id、room_type_ref_id、listed_price、结算价格、币种、库存数量、cancellation_policy、guarantee_policy
- 启用（类型：更新）
- 停用（类型：更新）
- 过期（类型：更新）
- 删除

#### 校验
- 创建时，租户编号 不能为空
- 创建时，供应商编码 不能为空
- 创建时，hotel_code 不能为空
- 创建时，room_type_code 不能为空
- 创建时，费率计划编码 不能为空
- 启用时，只有草稿或停用中的 offer 可以 activate
- 停用／过期时，只有 active 状态的 offer 可以 deactivate 或 expire

#### 变更
- 在 启用 时，将 销售状态 设为 启用
- 在 停用 时，将 销售状态 设为 停用
- 在 过期 时，将 销售状态 设为 已过期
- 在 创建 / 更新 / 启用 / 停用 / 过期 / 删除 时，将 编号 设为 编号

#### 事件
- 事件：启用 -> travel.catalog.hotel_offer.activated
- 事件：停用 -> travel.catalog.hotel_offer.deactivated
- 事件：过期 -> travel.catalog.hotel_offer.expired

#### 工作流
- 流程：hotel_offer_lifecycle：创建 -> 更新 -> 启用 -> 停用 -> 过期 -> 删除（酒店 offer 生命周期）

## 实体：FlightOffer（聚合根）

- 说明：机票可售 offer，承载航班、舱位、票规和库存快照

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 租户编号：唯一标识（必填）
- 宿主商城 ID，仅用于宿主侧隔离和桥接上下文（host_shop_id）：唯一标识
- 供应商编码：文本（必填），说明 供应商编码
- 行程编码（itinerary_code）：文本（必填）
- 航班号（flight_no）：文本（必填）
- 出发机场编码（departure_airport_code）：文本（必填）
- 到达机场编码（arrival_airport_code）：文本（必填）
- 离职：日期时间（必填），说明 起飞时间
- 到达：日期时间（必填），说明 到达时间
- 舱等（cabin_class）：文本（必填）
- 运价族（fare_family）：文本
- 对客展示价快照（listed_price）：金额（必填），必须 ≥ 0（listed_price 不能为负数）
- 结算价格：金额，必须 ≥ 0（settlement_price 不能为负数），说明 结算价快照
- 币种：文本，默认值 CNY
- 席位可用：整数，默认值 0，必须 ≥ 0（seats_available 不能为负数），说明 可售座位快照
- 行李规则快照（baggage_policy）：长文本
- 退款变更策略：长文本，说明 退改规则快照
- 销售状态：枚举，默认值 草稿，可选值：草稿 / 启用 / 停用 / 已过期
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- departure_airport_ref：多对一 -> TravelAirport，外键 departure_airport_ref_id
- arrival_airport_ref：多对一 -> TravelAirport，外键 arrival_airport_ref_id
- airline_ref：多对一 -> TravelAirline，外键 airline_ref_id
- cabin_class_ref：多对一 -> TravelCabinClass，外键 cabin_class_ref_id
- 订单：一对多 -> TravelOrder，外键 flight_offer_id

#### 唯一约束
- 唯一约束 unique_flight_offer_snapshot：租户编号、供应商编码、itinerary_code、flight_no、离职、cabin_class

### Conduct（行为声明）

#### 操作
- 创建，可写字段：租户编号、host_shop_id、供应商编码、itinerary_code、flight_no、airline_ref_id、departure_airport_code、departure_airport_ref_id、arrival_airport_code、arrival_airport_ref_id、离职、到达、cabin_class、cabin_class_ref_id、fare_family、listed_price、结算价格、币种、席位可用、baggage_policy、退款变更策略、销售状态
- 查询
- 更新，可写字段：airline_ref_id、departure_airport_ref_id、arrival_airport_ref_id、cabin_class_ref_id、listed_price、结算价格、币种、席位可用、baggage_policy、退款变更策略、fare_family
- 启用（类型：更新）
- 停用（类型：更新）
- 过期（类型：更新）
- 删除

#### 校验
- 创建时，租户编号 不能为空
- 创建时，供应商编码 不能为空
- 创建时，itinerary_code 不能为空
- 创建时，flight_no 不能为空
- 创建时，departure_airport_code 不能为空
- 创建时，arrival_airport_code 不能为空
- 创建时，cabin_class 不能为空
- 启用时，只有草稿或停用中的 offer 可以 activate
- 停用／过期时，只有 active 状态的 offer 可以 deactivate 或 expire

#### 变更
- 在 启用 时，将 销售状态 设为 启用
- 在 停用 时，将 销售状态 设为 停用
- 在 过期 时，将 销售状态 设为 已过期
- 在 创建 / 更新 / 启用 / 停用 / 过期 / 删除 时，将 编号 设为 编号

#### 事件
- 事件：启用 -> travel.catalog.flight_offer.activated
- 事件：停用 -> travel.catalog.flight_offer.deactivated
- 事件：过期 -> travel.catalog.flight_offer.expired

#### 工作流
- 流程：flight_offer_lifecycle：创建 -> 更新 -> 启用 -> 停用 -> 过期 -> 删除（机票 offer 生命周期）

## 实体：假期录用通知（聚合根）

- 说明：度假可售 offer，承载套餐、出发日期和预订规则快照

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 租户编号：唯一标识（必填）
- 宿主商城 ID，仅用于宿主侧隔离和桥接上下文（host_shop_id）：唯一标识
- 供应商编码：文本（必填），说明 供应商编码
- 包裹编码：文本（必填），说明 套餐编码
- 包裹名称：文本（必填），说明 套餐名称
- 包裹类型：枚举，默认值 group_tour，可选值：group_tour / free_travel / ticket_hotel / 自定义规则，说明 套餐类型
- 离职城市编码：文本（必填），说明 出发城市编码
- 目的地编码：文本（必填），说明 目的地编码
- 开始日期：日期（必填），说明 出行开始日期
- 结束日期：日期（必填），说明 出行结束日期
- 对客展示价快照（listed_price）：金额（必填），必须 ≥ 0（listed_price 不能为负数）
- 结算价格：金额，必须 ≥ 0（settlement_price 不能为负数），说明 结算价快照
- 币种：文本，默认值 CNY
- 库存数量：整数，默认值 0，必须 ≥ 0（inventory_count 不能为负数），说明 可售库存快照
- 预订规则快照（booking_rules）：长文本
- 取消规则快照（cancellation_policy）：长文本
- 销售状态：枚举，默认值 草稿，可选值：草稿 / 启用 / 停用 / 已过期
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 离职城市参考：多对一 -> TravelCity，外键 离职城市参考编号
- 目的地参考：多对一 -> TravelCity，外键 目的地参考编号
- 订单：一对多 -> TravelOrder，外键 假期录用通知编号

#### 唯一约束
- 唯一约束 唯一假期录用通知快照：租户编号、供应商编码、包裹编码、开始日期、结束日期

### Conduct（行为声明）

#### 操作
- 创建，可写字段：租户编号、host_shop_id、供应商编码、包裹编码、包裹名称、包裹类型、离职城市编码、离职城市参考编号、目的地编码、目的地参考编号、开始日期、结束日期、listed_price、结算价格、币种、库存数量、booking_rules、cancellation_policy、销售状态
- 查询
- 更新，可写字段：包裹名称、包裹类型、离职城市参考编号、目的地参考编号、listed_price、结算价格、币种、库存数量、booking_rules、cancellation_policy
- 启用（类型：更新）
- 停用（类型：更新）
- 过期（类型：更新）
- 删除

#### 校验
- 创建时，租户编号 不能为空
- 创建时，供应商编码 不能为空
- 创建时，包裹编码 不能为空
- 创建时，包裹名称 不能为空
- 创建时，离职城市编码 不能为空
- 创建时，目的地编码 不能为空
- 启用时，只有草稿或停用中的 offer 可以 activate
- 停用／过期时，只有 active 状态的 offer 可以 deactivate 或 expire

#### 变更
- 在 启用 时，将 销售状态 设为 启用
- 在 停用 时，将 销售状态 设为 停用
- 在 过期 时，将 销售状态 设为 已过期
- 在 创建 / 更新 / 启用 / 停用 / 过期 / 删除 时，将 编号 设为 编号

#### 事件
- 事件：启用 -> travel.catalog.vacation_offer.activated
- 事件：停用 -> travel.catalog.vacation_offer.deactivated
- 事件：过期 -> travel.catalog.vacation_offer.expired

#### 工作流
- 流程：vacation_offer_lifecycle：创建 -> 更新 -> 启用 -> 停用 -> 过期 -> 删除（度假 offer 生命周期）

## 实体：TrainOffer（聚合根）

- 说明：火车票可售 offer，承载车次、席别、候补和退改规则快照

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 租户编号：唯一标识（必填）
- 宿主商城 ID，仅用于宿主侧隔离和桥接上下文（host_shop_id）：唯一标识
- 供应商编码：文本（必填），说明 供应商编码
- 车次号（train_no）：文本（必填）
- 出发站编码（departure_station_code）：文本（必填）
- 出发站名称（departure_station_name）：文本（必填）
- 到达站编码（arrival_station_code）：文本（必填）
- 到达站名称（arrival_station_name）：文本（必填）
- 乘车日期（travel_date）：日期（必填）
- 离职：日期时间（必填），说明 发车时间
- 到达：日期时间（必填），说明 到达时间
- 席别名称（seat_class）：文本（必填）
- 席别编码（seat_code）：文本（必填）
- 是否无座票（is_no_seat）：布尔，默认值 否
- 库存状态：枚举，默认值 unavailable，可选值：可用 / waitlist_only / 已售销项 / unavailable，说明 余票或候补可用状态
- 是否支持候补（waitlist_supported）：布尔，默认值 否
- 对客展示价快照（listed_price）：金额（必填），必须 ≥ 0（listed_price 不能为负数）
- 结算价格：金额，必须 ≥ 0（settlement_price 不能为负数），说明 结算价快照
- 币种：文本，默认值 CNY
- 预订规则快照（booking_rules_snapshot）：长文本
- 变更规则快照：长文本，说明 改签规则快照
- 退款规则快照：长文本，说明 退票规则快照
- 销售状态：枚举，默认值 草稿，可选值：草稿 / 启用 / 停用 / 已过期，说明 可售状态
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- departure_station_ref：多对一 -> TravelStation，外键 departure_station_ref_id
- arrival_station_ref：多对一 -> TravelStation，外键 arrival_station_ref_id
- 订单：一对多 -> TravelOrder，外键 train_offer_id

#### 唯一约束
- 唯一约束 unique_train_offer_snapshot：租户编号、供应商编码、train_no、departure_station_code、arrival_station_code、travel_date、seat_code、is_no_seat

### Conduct（行为声明）

#### 操作
- 创建，可写字段：租户编号、host_shop_id、供应商编码、train_no、departure_station_code、departure_station_ref_id、departure_station_name、arrival_station_code、arrival_station_ref_id、arrival_station_name、travel_date、离职、到达、seat_class、seat_code、is_no_seat、库存状态、waitlist_supported、listed_price、结算价格、币种、booking_rules_snapshot、变更规则快照、退款规则快照、销售状态
- 查询
- 更新，可写字段：departure_station_ref_id、arrival_station_ref_id、departure_station_name、arrival_station_name、离职、到达、seat_class、is_no_seat、库存状态、waitlist_supported、listed_price、结算价格、币种、booking_rules_snapshot、变更规则快照、退款规则快照
- 启用（类型：更新）
- 停用（类型：更新）
- 过期（类型：更新）
- 删除

#### 校验
- 创建时，租户编号 不能为空
- 创建时，供应商编码 不能为空
- 创建时，train_no 不能为空
- 创建时，departure_station_code 不能为空
- 创建时，arrival_station_code 不能为空
- 创建时，seat_class 不能为空
- 创建时，seat_code 不能为空
- 启用时，只有草稿或停用中的 offer 可以 activate
- 停用／过期时，只有 active 状态的 offer 可以 deactivate 或 expire

#### 变更
- 在 启用 时，将 销售状态 设为 启用
- 在 停用 时，将 销售状态 设为 停用
- 在 过期 时，将 销售状态 设为 已过期
- 在 创建 / 更新 / 启用 / 停用 / 过期 / 删除 时，将 编号 设为 编号

#### 事件
- 事件：启用 -> travel.catalog.train_offer.activated
- 事件：停用 -> travel.catalog.train_offer.deactivated
- 事件：过期 -> travel.catalog.train_offer.expired

#### 工作流
- 流程：train_offer_lifecycle：创建 -> 更新 -> 启用 -> 停用 -> 过期 -> 删除（火车票 offer 生命周期）

## 实体：TravelOrder（聚合根）

- 说明：统一酒旅订单，承接 hotel、flight、vacation、train 四类商品的下单和状态流转；通过跨域引用关联 Sales::Customer 和 Payment::Payment

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 租户编号：唯一标识（必填）
- 宿主商城 ID，用于 sidecar 对接上下文（host_shop_id）：唯一标识
- 订单无：文本（必填），说明 订单号
- 产品类型：枚举，默认值 hotel，可选值：hotel / flight / 假期 / train，说明 商品类型
- train 订单预订模式（booking_mode）：枚举，默认值 标准，可选值：标准 / waitlist
- 联系人：文本（必填）
- 联系电话：文本（必填）
- 出行人数量（traveler_count）：整数，默认值 1，必须 ≥ 1（traveler_count 至少为 1）
- 合计金额：金额（必填），必须 ≥ 0（total_amount 不能为负数），说明 订单总金额
- 积分使用：整数，默认值 0，必须 ≥ 0（points_to_use 不能为负数），说明 计划使用的积分数量
- 积分扣款金额：金额，默认值 0，必须 ≥ 0（points_deduction_amount 不能为负数），说明 积分抵现金额
- 币种：文本，默认值 CNY
- 状态：枚举，默认值 草稿，可选值：草稿 / quoted / 已提交 / booking_pending / booked / 取消待处理 / 已取消 / 已完成 / 失败
- 变更状态：枚举，默认值 无，可选值：无 / 待处理 / 变更 / 失败
- waitlist_status：枚举，默认值 无，可选值：无 / 待处理 / fulfilled / 已取消 / 失败
- 原始订单参考：文本，说明 改签链路引用的原订单号或原票号
- 出票乘客信息：映射，说明 乘车人信息快照
- 选座与席别偏好快照（seat_selection_snapshot）：映射
- 供应商订单参考：文本，说明 供应商订单号
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- hotel_offer：多对一 -> HotelOffer，外键 hotel_offer_id
- flight_offer：多对一 -> FlightOffer，外键 flight_offer_id
- 假期录用通知：多对一 -> 假期录用通知，外键 假期录用通知编号
- train_offer：多对一 -> TrainOffer，外键 train_offer_id
- fulfillments：一对多 -> TravelFulfillment，外键 travel_order_id
- 客户：多对一 -> 客户，外键 客户编号
- 付款：多对一 -> 付款，外键 付款编号

#### 唯一约束
- 唯一约束 唯一订单无：订单无

### Conduct（行为声明）

#### 操作
- 创建订单（类型：创建），可写字段：租户编号、host_shop_id、hotel_offer_id、flight_offer_id、假期录用通知编号、train_offer_id、订单无、产品类型、客户编号、联系人、联系电话、traveler_count、合计金额、积分使用、积分扣款金额、币种、出票乘客信息、seat_selection_snapshot
- 查询
- 更新，可写字段：联系人、联系电话、traveler_count、出票乘客信息、seat_selection_snapshot
- 确认报价（类型：更新）
- 提交订单（类型：更新）
- submit_waitlist（类型：更新）
- mark_payment_succeeded（类型：更新）
- mark_booked（类型：更新）
- fulfill_waitlist（类型：更新）
- 标记已完成（类型：更新）
- 请求取消（类型：更新）
- cancel_waitlist（类型：更新）
- 审批取消（类型：更新）
- 请求变更（类型：更新），可写字段：原始订单参考
- 确认变更（类型：更新）
- 标记订单失败（类型：更新）
- 删除

#### 校验
- 创建订单时，租户编号 不能为空
- 创建订单时，订单无 不能为空
- 创建订单时，客户编号 不能为空
- 创建订单时，联系人 不能为空
- 创建订单时，联系电话 不能为空
- 创建订单时，二选一（hotel_offer_id、flight_offer_id、vacation_offer_id、train_offer_id 必须四选一）
- 创建订单时，hotel_offer_id 不能为空（hotel 订单必须绑定 hotel_offer_id），前提：产品类型 = hotel
- 创建订单时，flight_offer_id 不能为空（flight 订单必须绑定 flight_offer_id），前提：产品类型 = flight
- 创建订单时，假期录用通知编号 不能为空（vacation 订单必须绑定 vacation_offer_id），前提：产品类型 = 假期
- 创建订单时，train_offer_id 不能为空（train 订单必须绑定 train_offer_id），前提：产品类型 = train
- 确认报价时，只有 draft 订单可以 confirm_quote
- 提交订单／submit_waitlist时，只有 quoted 订单可以提交普通购票或候补
- mark_payment_succeeded／标记订单失败时，只有 submitted 订单可以进入支付成功或失败结果
- mark_booked／fulfill_waitlist／cancel_waitlist时，只有 booking_pending 订单可以完成出票、兑现候补或取消候补
- 标记已完成／请求取消／请求变更时，只有 booked 订单可以完成、取消或改签
- 审批取消时，只有 cancel_pending 订单可以 approve_cancel
- fulfill_waitlist／cancel_waitlist时，只有 waitlist_pending 的订单可以兑现或取消候补
- 确认变更时，只有 change_pending 的订单可以 confirm_change
- 请求变更／确认变更时，原始订单参考 不能为空

#### 变更
- 在 确认报价 时，将 状态 设为 quoted
- 在 提交订单 / submit_waitlist 时，将 状态 设为 已提交
- 在 submit_waitlist 时，将 booking_mode 设为 waitlist
- 在 submit_waitlist 时，将 waitlist_status 设为 待处理
- 在 mark_payment_succeeded 时，将 状态 设为 booking_pending
- 在 mark_booked / fulfill_waitlist 时，将 状态 设为 booked
- 在 fulfill_waitlist 时，将 waitlist_status 设为 fulfilled
- 在 标记已完成 时，将 状态 设为 已完成
- 在 请求取消 时，将 状态 设为 取消待处理
- 在 cancel_waitlist / 审批取消 时，将 状态 设为 已取消
- 在 cancel_waitlist 时，将 waitlist_status 设为 已取消
- 在 请求变更 时，将 变更状态 设为 待处理
- 在 确认变更 时，将 变更状态 设为 变更
- 在 标记订单失败 时，将 状态 设为 失败
- 在 创建订单 / 更新 / 确认报价 / 提交订单 / submit_waitlist / mark_payment_succeeded / mark_booked / fulfill_waitlist / 标记已完成 / 请求取消 / cancel_waitlist / 审批取消 / 请求变更 / 确认变更 / 标记订单失败 / 删除 时，将 编号 设为 编号

#### 计算
- 计算字段 应付金额：金额，规则 合计金额 - 积分扣款金额

#### 事件
- 事件：提交订单 -> travel.订单.已提交
- 事件：submit_waitlist -> travel.order.waitlist_submitted
- 事件：mark_payment_succeeded -> travel.order.payment_confirmed
- 事件：fulfill_waitlist -> travel.order.waitlist_fulfilled
- 事件：cancel_waitlist -> travel.order.waitlist_cancelled
- 事件：审批取消 -> travel.订单.已取消
- 事件：确认变更 -> travel.order.change_confirmed
- 事件：标记订单失败 -> travel.订单.失败

#### 工作流
- 流程：travel_order_lifecycle：创建订单 -> 更新 -> 确认报价 -> 提交订单 -> submit_waitlist -> mark_payment_succeeded -> mark_booked -> fulfill_waitlist -> cancel_waitlist -> 请求取消 -> 审批取消 -> 请求变更 -> 确认变更 -> 标记已完成 -> 标记订单失败 -> 删除（统一酒旅订单生命周期，覆盖 train 候补与改签分支；退款由 Payment 域处理）

#### 集成契约
- 宿主商城上下文解析，绑定动作：创建订单；模式：同步；请求字段：租户编号、host_shop_id、客户编号；响应字段：context_verified、current_shop_id、成员编号、enterprise_id；错误码：宿主上下文不存在（不可重试）、宿主上下文超时（可重试）；说明：创建订单时调用宿主 shop caller context 契约，校验并回填当前商城/会员上下文
- 宿主商城可支付性预检，绑定动作：确认报价；模式：同步；请求字段：租户编号、host_shop_id、客户编号、产品类型、合计金额、积分使用、币种；响应字段：travel_enabled、积分付款允许、mixed_payment_allowed、可用积分、recommended_payment_mode、报价追踪编号；错误码：宿主预检驳回（不可重试）、宿主预检超时（可重试）；说明：报价确认阶段调用宿主 shop eligibility/quote 契约，返回可支付性与积分策略语义
- 宿主支付执行，绑定动作：提交订单 / submit_waitlist；模式：同步；请求字段：订单无、应付金额、币种、客户编号、host_shop_id、booking_mode；响应字段：付款编号、付款状态、captured_amount、供应商追踪编号；错误码：付款已拒绝（不可重试）、付款超时（可重试）、付款风险已驳回（不可重试）；说明：提交订单后调用宿主 shop payment execution 契约，失败时按声明错误码驱动补偿路径
- 供应商预订提交，绑定动作：mark_payment_succeeded；模式：async；请求字段：订单无、产品类型、traveler_count、供应商订单参考；错误码：供应商超时（可重试）、supplier_inventory_unavailable（不可重试）；异步配置：队列 travel_supplier_booking，超时 120000ms；说明：支付成功后异步提交供应商预订，失败时回滚 booking_pending 并转失败处理

## 实体：TravelFulfillment（聚合根）

- 说明：统一酒旅履约聚合，承接预订确认、发券出票、候补兑现、乘车使用和失败结果；可选关联 Delivery::Shipment

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 租户编号：唯一标识（必填）
- 履行类型：枚举，默认值 reserve_room，可选值：reserve_room / 问题工单 / 问题凭单 / issue_train_ticket
- 状态：枚举，默认值 待处理，可选值：待处理 / 已确认 / 签发 / 包含使用 / 已完成 / 已取消 / 失败
- 供应商预订号（supplier_booking_ref）：文本
- 凭证或票据参考：文本，说明 凭证号或票号
- 票据引用：映射，说明 多张票号、座席和乘客映射结果
- train 候补兑现结果（waitlist_result）：枚举，默认值 无，可选值：无 / 待处理 / fulfilled / 已取消 / 失败
- 变更结果：枚举，默认值 无，可选值：无 / 待处理 / 变更 / 失败，说明 train 改签结果
- train 乘车状态（boarding_status）：枚举，默认值 非开始，可选值：非开始 / boarded / 已完成
- 确认结果快照（confirmation_payload）：长文本
- 失败原因：长文本，说明 失败原因
- 已用：日期时间，说明 实际使用时间
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 订单：多对一 -> TravelOrder，外键 travel_order_id，必填关系
- 发货：多对一 -> 发货，外键 发货编号

### Conduct（行为声明）

#### 操作
- 创建履行（类型：创建），可写字段：租户编号、travel_order_id、履行类型、supplier_booking_ref
- 查询
- 更新，可写字段：supplier_booking_ref、凭证或票据参考、票据引用、confirmation_payload、失败原因
- confirm_booking（类型：更新）
- 发券或出票（类型：更新）
- 标记包含使用（类型：更新），可写字段：已用
- 完成履行（类型：更新）
- 取消履行（类型：更新）
- 失败履行（类型：更新），可写字段：失败原因
- 删除

#### 校验
- 创建履行时，租户编号 不能为空
- confirm_booking／失败履行／取消履行时，只有 pending 履约可以确认、失败或取消
- 发券或出票时，只有 confirmed 履约可以 issue_voucher_or_ticket
- 标记包含使用时，只有 issued 履约可以 mark_in_use
- 完成履行时，只有 issued 或 in_use 履约可以 complete_fulfillment

#### 变更
- 在 confirm_booking 时，将 状态 设为 已确认
- 在 发券或出票 时，将 状态 设为 签发
- 在 标记包含使用 时，将 状态 设为 包含使用
- 在 完成履行 时，将 状态 设为 已完成
- 在 取消履行 时，将 状态 设为 已取消
- 在 失败履行 时，将 状态 设为 失败
- 在 创建履行 / 更新 / confirm_booking / 发券或出票 / 标记包含使用 / 完成履行 / 取消履行 / 失败履行 / 删除 时，将 编号 设为 编号

#### 事件
- 事件：confirm_booking -> travel.履行.已确认
- 事件：发券或出票 -> travel.履行.签发
- 事件：完成履行 -> travel.履行.已完成
- 事件：取消履行 -> travel.履行.已取消
- 事件：失败履行 -> travel.履行.失败

#### 工作流
- 流程：travel_fulfillment_lifecycle：创建履行 -> 更新 -> confirm_booking -> 发券或出票 -> 标记包含使用 -> 完成履行 -> 取消履行 -> 失败履行 -> 删除（统一酒旅履约生命周期）

#### 集成契约
- 供应商预订确认，绑定动作：confirm_booking；模式：同步；请求字段：travel_order_id、履行类型、supplier_booking_ref；响应字段：确认状态、supplier_booking_ref、confirmation_payload；错误码：supplier_booking_rejected（不可重试）、供应商超时（可重试）；说明：预订确认同步契约，前置依赖 TravelOrder 已完成 shop_caller_context_resolve、shop_eligibility_quote、payment_capture；失败时需保留 pending 并可重试或转 fail_fulfillment
- 供应商发券出票，绑定动作：发券或出票；模式：同步；请求字段：travel_order_id、履行类型、出票乘客信息；响应字段：发券出票状态、凭证或票据参考、票据引用；错误码：发券出票失败（不可重试）、发券出票超时（可重试）；说明：发券出票同步契约，失败时走 fail_fulfillment 并记录 failure_reason
- 供应商取消预订，绑定动作：取消履行；模式：async；请求字段：travel_order_id、supplier_booking_ref；错误码：取消超时（可重试）、取消已驳回（不可重试）；异步配置：队列 travel_supplier_cancel，超时 60000ms；说明：取消履约异步契约，失败时通过补偿任务做二次撤销

