# 模型业务说明

- 版本：1.0
- 领域：DataRecycle
- 领域说明：数据回收领域模型，涵盖回收规则配置和待回收记录管理，支持按时间维度自动/手动清理过期数据
- 实体数量：4

## 实体：RecycleModel（聚合根）

- 说明：回收规则配置——定义哪些模型的数据需要按时间维度进行回收（归档或删除）
- 来源：基于 RecycleModel；来源域 data_recycle/data_recycle

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本（必填），说明 规则名称
- 资源模型名称：文本（必填），说明 目标模型名称（如 sale.order）
- 域：文本，说明 过滤条件（JSON 格式域表达式）
- 时间字段：文本（必填），说明 用于判断过期的时间字段名（如 create_date、write_date）
- 时间差值（time_field_delta）：整数（必填），默认值 1
- 时间差值单位（time_field_delta_unit）：枚举，默认值 月，可选值：天数 / 周 / 月 / 年数
- 回收模式；manual 需人工确认，automatic 由定时任务自动执行（recycle_mode）：枚举，默认值 手动，可选值：手动 / 自动
- 回收动作；archive 归档（soft delete），delete 物理删除（recycle_action）：枚举，默认值 归档，可选值：归档 / 删除
- 包含已归档：布尔，默认值 否，说明 是否包含已归档记录
- 启用：布尔，默认值 是，说明 是否启用
- 通知频率：整数，默认值 1，说明 通知频率数值
- 通知频率期间：枚举，默认值 周，可选值：天数 / 周 / 月，说明 通知频率单位
- 最近通知：日期时间，说明 上次通知时间
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- recycle_records：一对多 -> RecycleRecord
- 通知用户：多对多 -> 参与方，外键 通知用户参与方编号，中间关系 RecycleModelNotifyUser

### Conduct（行为声明）

#### 操作
- 创建，可写字段：名称、资源模型名称、域、时间字段、time_field_delta、time_field_delta_unit、recycle_mode、recycle_action、包含已归档、启用、通知频率、通知频率期间
- 查询
- 更新，可写字段：名称、资源模型名称、域、时间字段、time_field_delta、time_field_delta_unit、recycle_mode、recycle_action、包含已归档、启用、通知频率、通知频率期间
- 删除
- recycle_records_action（类型：更新），说明：手动触发回收——根据规则搜索符合条件的记录，自动模式直接执行，手动模式创建待审记录
- cron_recycle（类型：更新），说明：定时任务入口——扫描所有启用的规则并执行回收

#### 校验
- recycle_action inclusion（回收动作只能是 archive 或 delete）
- 创建时，名称 不能为空
- 创建时，资源模型名称 不能为空
- 创建时，时间字段 不能为空

#### 变更
- 在 创建 / 更新 / 删除 / recycle_records_action / cron_recycle 时，将 编号 设为 编号

#### 计算
- 计算字段 records_to_recycle_count：整数，规则 count(recycle_records)

#### 工作流
- 流程：recycle_model_lifecycle：创建 -> 更新 -> recycle_records_action -> cron_recycle -> 删除（回收规则维护与执行流程）

## 实体：RecycleRecord

- 说明：待回收记录——由回收规则扫描产生，等待人工确认或自动执行
- 来源：基于 RecycleRecord；来源域 data_recycle/data_recycle

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 资源编号：整数（必填），说明 原始记录 ID
- 资源模型名称：文本，说明 原始记录所属模型名称
- 名称：文本，说明 原始记录的显示名称
- 启用：布尔，默认值 是，说明 是否活跃；忽略后设为 false
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- recycle_model：多对一 -> RecycleModel，必填关系

### Conduct（行为声明）

#### 操作
- 创建，可写字段：资源编号、资源模型名称、名称、启用，参数：recycle_model_id：唯一标识（必填）
- 查询
- 验证（类型：更新），说明：确认回收——执行归档或删除原始记录
- discard（类型：更新），说明：忽略——将 active 设为 false，不再显示

#### 校验
- 创建时，资源编号 不能为空
- 验证／discard时，仅活跃待回收记录可执行确认或忽略

#### 变更
- 在 discard 时，将 启用 设为 否
- 在 创建 / 验证 / discard 时，将 编号 设为 编号

#### 工作流
- 流程：recycle_record_processing：创建 -> 验证 -> discard（待回收记录处理流程）

## 实体：RecycleModelNotifyUser

- 说明：回收规则通知用户关联表——多对多桥接
- 来源：基于 联系列表参与方；来源域 ofbiz/marketing

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）

#### 关系
- recycle_model：多对一 -> RecycleModel，必填关系
- 用户：多对一 -> 参与方，外键 用户参与方编号，必填关系

### Conduct（行为声明）

#### 操作
- 创建，参数：recycle_model_id：唯一标识（必填）；用户编号：唯一标识（必填）
- 查询
- 删除

#### 校验
- 创建时，recycle_model_id 和 user_id 必须传入
- 删除时，仅已存在的通知关联可删除

#### 变更
- 在 创建 / 删除 时，将 编号 设为 编号

#### 工作流
- 流程：recycle_model_notify_user_management：创建 -> 删除（回收规则通知用户关联维护流程）

## 实体：参与方

- 说明：跨域引用 Organization.Party（统一主体）

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本

### Conduct（行为声明）

#### 操作
- 查询

