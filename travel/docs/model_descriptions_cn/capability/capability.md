# 模型业务说明

- 版本：1.0
- 领域：Capability
- 领域说明：战略目标、业务能力与业务模块的追溯模型
- 实体数量：4

## 实体：StrategicGoal（聚合根）

- 说明：战略目标，表达企业层面的阶段性方向与治理诉求

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 战略目标稳定标识（goal_code）：文本（必填）
- 名称：文本（必填），说明 战略目标名称
- 目标时间跨度（horizon）：枚举（必填），默认值 phase2，可选值：phase2 / annual / 多年
- 期望业务结果描述（outcome_statement）：文本
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 能力：一对多 -> BusinessCapability，外键 strategic_goal_id

#### 唯一约束
- 唯一约束 unique_goal_code：goal_code

### Conduct（行为声明）

#### 操作
- 查询
- 创建，可写字段：goal_code、名称、horizon、outcome_statement
- 更新，可写字段：名称、horizon、outcome_statement

#### 变更
- 在 创建 / 更新 时，将 编号 设为 编号

## 实体：BusinessCapability（聚合根）

- 说明：业务能力，表达组织希望沉淀和复用的业务处理能力

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 能力稳定标识（capability_code）：文本（必填）
- 名称：文本（必填），说明 能力名称
- 能力层级（capability_level）：枚举（必填），默认值 capability，可选值：域 / subdomain / capability
- 该能力支撑的业务结果（outcome_statement）：文本
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- strategic_goal：多对一 -> StrategicGoal，外键 strategic_goal_id，必填关系
- parent_capability：多对一 -> BusinessCapability，外键 parent_capability_id
- 下级能力：一对多 -> BusinessCapability，外键 parent_capability_id
- module_mappings：一对多 -> ModuleCapabilityMapping，外键 capability_id

#### 唯一约束
- 唯一约束 unique_capability_code：capability_code

### Conduct（行为声明）

#### 操作
- 查询
- 创建，可写字段：capability_code、名称、capability_level、outcome_statement，参数：strategic_goal_id：唯一标识（必填）；parent_capability_id：唯一标识
- 更新，可写字段：名称、capability_level、outcome_statement

#### 变更
- 在 创建 / 更新 时，将 编号 设为 编号

## 实体：BusinessModule（聚合根）

- 说明：业务模块注册表，记录被能力追溯覆盖的模块

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 模块键：枚举（必填），可选值：质量 / 采购 / 销售 / 配送，说明 第二阶段首批纳入追溯的模块标识
- 名称：文本（必填），说明 模块名称
- 模型路径：文本（必填），说明 模块主模型路径
- 当前追溯阶段（phase）：枚举（必填），默认值 phase2，可选值：phase2
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- capability_mappings：一对多 -> ModuleCapabilityMapping，外键 business_module_id

#### 唯一约束
- 唯一约束 唯一模块键：模块键

### Conduct（行为声明）

#### 操作
- 查询
- 创建，可写字段：模块键、名称、模型路径、phase
- 更新，可写字段：名称、模型路径、phase

#### 变更
- 在 创建 / 更新 时，将 编号 设为 编号

## 实体：ModuleCapabilityMapping（聚合根）

- 说明：模块与能力的绑定关系，用于反查 capability 与 module

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 模块对能力的支撑角色（mapping_role）：枚举（必填），默认值 主要所有者，可选值：主要所有者 / supporting
- 绑定原因说明（rationale）：文本
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- business_module：多对一 -> BusinessModule，外键 business_module_id，必填关系
- capability：多对一 -> BusinessCapability，外键 capability_id，必填关系

#### 唯一约束
- 唯一约束 unique_module_capability：business_module_id、capability_id

### Conduct（行为声明）

#### 操作
- 查询
- 创建，可写字段：mapping_role、rationale，参数：business_module_id：唯一标识（必填）；capability_id：唯一标识（必填）
- 更新，可写字段：mapping_role、rationale

#### 变更
- 在 创建 / 更新 时，将 编号 设为 编号

