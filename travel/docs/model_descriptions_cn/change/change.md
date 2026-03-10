# 模型业务说明

- 版本：1.0
- 领域：变更
- 领域说明：变更管理域，统一承接变更提出、影响分析、审批、实施、验证与关闭流程
- 实体数量：2

## 实体：变更请求（聚合根）

- 说明：变更请求，关联 GitHub issue、影响分析结果与验证结果，驱动完整变更生命周期

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 标题：文本（必填），说明 变更标题
- 说明：长文本，说明 变更说明
- 变更类型：枚举（必填），可选值：schema_change / 流程变更 / 组织变更 / 策略变更 / capability_change，说明 变更类型
- 状态：枚举（必填），默认值 proposed，可选值：proposed / impact_analyzed / 已审批 / implementing / 已验证 / 已关闭 / 已驳回，说明 变更状态
- GitHub问题链接：文本（必填），说明 关联的 GitHub issue 链接
- 影响报表：jsonb，默认值 ，说明 影响分析结果，最小先承接编译/漂移/gate 摘要
- 验证结果：jsonb，默认值 ，说明 验证结果，记录测试与验收证据摘要
- 审批备注：长文本，说明 审批说明
- 实施说明（implementation_notes）：长文本
- 拒绝原因：长文本，说明 拒绝原因
- 完成影响分析时间（impact_analyzed_at）：日期时间
- 已审批：日期时间，说明 审批通过时间
- 开始实施时间（implementation_started_at）：日期时间
- 已验证：日期时间，说明 完成验证时间
- 已关闭：日期时间，说明 关闭时间
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 请求人：多对一 -> 参与方，外键 请求人参与方编号，必填关系
- 已审批：多对一 -> 参与方，外键 已审批参与方编号
- 已验证：多对一 -> 参与方，外键 已验证参与方编号

### Conduct（行为声明）

#### 操作
- 创建，可写字段：标题、说明、变更类型、GitHub问题链接、请求人参与方编号
- 查询
- 更新，可写字段：标题、说明、GitHub问题链接
- analyze_impact（类型：更新），说明：写入影响分析结果并推进到 impact_analyzed，可写字段：影响报表
- 审批（类型：更新），说明：审批通过并推进到 approved，可写字段：审批备注、已审批参与方编号
- start_implementation（类型：更新），说明：开始实施并推进到 implementing，可写字段：implementation_notes
- 核实（类型：更新），说明：写入验证结果并推进到 verified，可写字段：验证结果、已验证参与方编号
- 关闭（类型：更新），说明：完成关闭并推进到 closed
- 驳回（类型：更新），说明：拒绝变更请求并推进到 rejected，可写字段：拒绝原因

#### 校验
- 创建时，标题 不能为空
- 创建时，变更类型 不能为空
- 创建时，GitHub问题链接 不能为空
- analyze_impact时，只有 proposed 状态可以执行影响分析
- 审批时，只有 impact_analyzed 状态可以审批通过
- 驳回时，只有 impact_analyzed 状态可以拒绝
- start_implementation时，只有 approved 状态可以开始实施
- 核实时，只有 implementing 状态可以写入验证结果
- 关闭时，只有 verified 状态可以关闭
- analyze_impact时，影响报表 不能为空（影响分析阶段必须提供 impact_report）
- 核实时，验证结果 不能为空（验证阶段必须提供 verification_result）

#### 策略
- 权限：创建 操作，当 操作者.角色 属于 变更经理、管理员 时允许
- 权限：查询 操作，当 操作者.角色 = 管理员 或 op=relates_to_actor_via，args=请求人 时允许
- 权限：更新 操作，当 操作者.角色 = 管理员 或 op=relates_to_actor_via，args=请求人 时允许

#### 变更
- 在 analyze_impact 时，将 状态 设为 impact_analyzed
- 在 analyze_impact 时，将 impact_analyzed_at 设为 当前时间
- 在 审批 时，将 状态 设为 已审批
- 在 审批 时，将 已审批 设为 当前时间
- 在 start_implementation 时，将 状态 设为 implementing
- 在 start_implementation 时，将 implementation_started_at 设为 当前时间
- 在 核实 时，将 状态 设为 已验证
- 在 核实 时，将 已验证 设为 当前时间
- 在 关闭 时，将 状态 设为 已关闭
- 在 关闭 时，将 已关闭 设为 当前时间
- 在 驳回 时，将 状态 设为 已驳回
- 在 创建 / 更新 / analyze_impact / 审批 / start_implementation / 核实 / 关闭 / 驳回 时，将 编号 设为 编号

#### 事件
- 事件：analyze_impact -> change.request.impact_analyzed
- 事件：审批 -> 变更.请求.已审批
- 事件：核实 -> 变更.请求.已验证
- 事件：关闭 -> 变更.请求.已关闭
- 事件：驳回 -> 变更.请求.已驳回

#### 工作流
- 流程：change_request_lifecycle：创建 -> 更新 -> analyze_impact -> 审批 -> start_implementation -> 核实 -> 关闭 -> 驳回（变更请求生命周期）

## 实体：参与方

- 说明：跨域引用 Organization.Party（统一主体）

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本

### Conduct（行为声明）

#### 操作
- 查询

