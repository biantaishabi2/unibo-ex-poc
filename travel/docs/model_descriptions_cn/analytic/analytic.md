# 模型业务说明

- 版本：1.0
- 领域：分析
- 领域说明：分析会计领域模型，支持多维度成本/收入分析；平行于总账运行，为项目制计费、部门核算提供基础
- 实体数量：9

## 实体：分析计划（聚合根）

- 说明：分析维度计划，定义一套分析账户的分类维度（如"项目"、"部门"、"成本类别"）
- 来源：基于 总账科目类型；来源域 ofbiz/accounting；过滤条件 作为 AnalyticPlan 原型：GlAccountType 提供了 parent_type_id 层级和 description；Analytic 场景下独立建模

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本（必填），说明 计划名称（如"项目维度"、"部门维度"）
- 编码：文本，说明 计划编码，用于快速引用
- 说明：长文本，说明 计划说明
- 颜色：整数，默认值 0，说明 看板颜色（UI 标识）
- 在凭证分录行中的默认适用性：
optional = 可填可不填
mandatory = 必填
unavailable = 本计划不在该场景下显示
（default_applicability）：枚举，默认值 可选，可选值：可选 / 必填 / unavailable
- 是否启用：布尔，默认值 是，说明 是否启用；停用后不允许新建该计划下的分析账户
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 科目：一对多 -> 分析科目，外键 计划编号

#### 唯一约束
- 唯一约束 唯一计划编码：编码

### Conduct（行为声明）

#### 操作
- 创建，可写字段：名称、编码、说明、颜色、default_applicability
- 查询
- 更新，可写字段：名称、编码、说明、颜色、default_applicability、是否启用
- 停用（类型：更新），说明：停用分析计划

#### 校验
- 创建时，名称 不能为空

#### 变更
- 在 停用 时，将 是否启用 设为 否
- 在 创建 / 更新 / 停用 时，将 编号 设为 编号

#### 工作流
- 流程：analytic_plan_lifecycle：创建 -> 更新 -> 停用（分析计划管理流程）

## 实体：分析科目（聚合根）

- 说明：分析账户（成本中心/利润中心/项目账户），支持多级层级，归属于某一 AnalyticPlan
- 来源：基于 总账科目；来源域 ofbiz/accounting；过滤条件 GlAccount 字段映射：
  account_code     → code
  account_name     → name
  parent_gl_account_id → parent_id（自引用层级）
  description      → description
GlAccountOrganization 字段映射：
  organization_party_id → partner_id（所有者/负责方）
  from_date         → date_start
  thru_date         → date_stop


### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 编码：文本，说明 分析账户编码 [R-ANL-001]
- 名称：文本（必填），说明 分析账户名称（如"华南大区项目"、"研发部门"）
- 日期开始：日期，说明 有效期开始（来自 GlAccountOrganization.from_date）
- 日期停止：日期，说明 有效期结束（来自 GlAccountOrganization.thru_date）
- 是否启用：布尔，默认值 是，说明 是否启用；停用后不可用于新 AnalyticLine [R-ANL-003]
- 说明：长文本
- 余额：金额，默认值 0，说明 余额汇总（计算字段）
公式：SUM(analytic_line.amount) WHERE account_id = self.id
来自 GlAccountHistory.ending_balance 原型

- 借方：金额，默认值 0，说明 借方汇总（计算字段）
公式：SUM(analytic_line.amount) WHERE amount > 0
来自 GlAccountHistory.posted_debits 原型

- 贷方：金额，默认值 0，说明 贷方汇总（计算字段）
公式：SUM(ABS(analytic_line.amount)) WHERE amount < 0
来自 GlAccountHistory.posted_credits 原型

- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 计划：多对一 -> 分析计划，必填关系
- 上级：多对一 -> 分析科目
- 子项：一对多 -> 分析科目，外键 上级编号
- 伙伴：多对一 -> 参与方，外键 伙伴参与方编号
- 分析明细行：一对多 -> 分析行，外键 科目编号

#### 唯一约束
- 唯一约束 唯一编码每计划：计划编号、编码

### Conduct（行为声明）

#### 操作
- 创建，可写字段：编码、名称、计划编号、上级编号、伙伴编号、日期开始、日期停止、说明
- 查询
- 更新，可写字段：编码、名称、上级编号、伙伴编号、日期开始、日期停止、说明、是否启用
- 停用（类型：更新），说明：停用分析账户 [R-ANL-003]

#### 校验
- 创建时，名称 不能为空
- 创建时，计划编号 不能为空

#### 变更
- 在 停用 时，将 是否启用 设为 否
- 在 创建 / 更新 / 停用 时，将 编号 设为 编号

#### 计算
- 计算字段 余额：金额，规则 合计关联(分析明细行, 金额)
- 计算字段 借方：金额，规则 sum_related_filtered(分析明细行, 金额, 金额 > 0)
- 计算字段 贷方：金额，规则 sum_related_filtered(分析明细行, 金额, 金额 < 0)

#### 事件
- 事件：停用 -> 分析.科目.deactivated

#### 工作流
- 流程：analytic_account_lifecycle：创建 -> 更新 -> 停用（分析账户管理流程）

## 实体：分析行

- 说明：分析行，记录某一时点在某分析账户下发生的成本/收入金额；可由 JournalEntryLine 自动生成，也可手动录入
- 来源：基于 会计分录；来源域 ofbiz/accounting；过滤条件 AcctgTransEntry 字段映射：
  gl_account_id     → 对应 account_id（分析账户，非总账）
  amount            → amount
  party_id          → partner_id
  description       → name
  currency_uom_id   → currency_id
AcctgTrans 字段映射：
  transaction_date  → date
  is_posted         → （作为 auto_generated 标志原型）
  invoice_id        → move_line_id 溯源
  work_effort_id    → 扩展字段


### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 日期：日期（必填），说明 发生日期 [R-ANL-005]
- 名称：文本（必填），说明 摘要（来自 AcctgTransEntry.description）
- 金额：金额（必填），说明 金额，正值=收入/借方，负值=成本/贷方 [R-ANL-006]
来自 AcctgTransEntry.amount（借贷方向由符号表示）

- 单位金额：金额，默认值 0，说明 数量（用于工时/工单场景，配合 product_uom_id 使用）
- 自动已生成：布尔，默认值 否，说明 是否由系统自动生成（过账时从 JournalEntryLine 的 analytic_distribution 展开）
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 科目：多对一 -> 分析科目，必填关系
- 伙伴：多对一 -> 参与方，外键 伙伴参与方编号
- 移动行：多对一 -> 日记账凭证行
- 币种：多对一 -> 币种
- 产品：多对一 -> 产品
- 员工：多对一 -> 员工
- 公司：多对一 -> 参与方，外键 公司参与方编号

### Conduct（行为声明）

#### 操作
- 创建，可写字段：日期、名称、金额、单位金额、科目编号、伙伴编号、币种编号、产品编号、员工编号
- 查询
- 更新，说明：仅手动行（auto_generated=false）可修改，可写字段：日期、名称、金额、单位金额、伙伴编号
- 删除，说明：删除前检查关联 JournalEntryLine 是否已过账 [R-ANL-007]

#### 校验
- 创建时，日期 不能为空
- 创建时，名称 不能为空
- 创建时，金额 不能为空

#### 变更
- 在 创建 / 更新 / 删除 时，写入/删除后触发 AnalyticAccount.balance/debit/credit 重算
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

#### 事件
- 事件：创建 -> 分析.行.已过账
- 事件：删除 -> 分析.行.deleted

#### 工作流
- 流程：分析行手动：创建 -> 更新 -> 删除（手动分析行录入流程）

## 实体：AnalyticDistribution

- 说明：分摊规则，将一笔金额按百分比自动分配到多个 AnalyticAccount；附加在 JournalEntryLine 上
- 来源：基于 AnalyticDistribution；来源域 分析；过滤条件 OFBiz 无直接对应实体；参考 Odoo account.analytic.distribution（JSON字段展开为独立记录）

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 百分比：金额（必填），说明 分摊百分比（0-100），所有 move_line_id 相同的记录合计必须=100 [R-ANL-004]
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 移动行：多对一 -> 日记账凭证行，必填关系
- 科目：多对一 -> 分析科目，必填关系

### Conduct（行为声明）

#### 操作
- 创建，可写字段：移动行编号、科目编号、百分比
- 查询
- 更新，可写字段：百分比
- 删除

#### 校验
- 创建／更新时，百分比 必须大于 0，且 必须 ≤ 100（分摊百分比必须在 0~100 之间）

#### 变更
- 在 创建 / 更新 / 删除 时，[R-ANL-008] 创建/修改分摊规则后，重新生成 AnalyticLine（若 JournalEntry 已过账）
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

#### 事件
- 事件：创建 -> 分析.distribution.已应用
- 事件：更新 -> 分析.distribution.变更

#### 工作流
- 流程：analytic_distribution_setup：创建 -> 更新 -> 删除（分摊规则配置流程）

## 实体：日记账凭证行

- 说明：凭证分录行占位实体（跨域引用 Accounting 域，最小字段）
- 来源：基于 会计分录；来源域 ofbiz/accounting

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 说明：文本

### Conduct（行为声明）

#### 操作
- 查询

## 实体：币种

- 说明：币种占位实体（跨域引用，最小字段）
- 来源：基于 单位；来源域 ofbiz/common；过滤条件 uomTypeId = CURRENCY_MEASURE

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本

### Conduct（行为声明）

#### 操作
- 查询

## 实体：产品

- 说明：产品占位实体（跨域引用，最小字段）
- 来源：基于 产品；来源域 ofbiz/product

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本

### Conduct（行为声明）

#### 操作
- 查询

## 实体：员工

- 说明：员工占位实体（跨域引用，最小字段）
- 来源：基于 人员；来源域 ofbiz/party；过滤条件 roleTypeId = EMPLOYEE

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本

### Conduct（行为声明）

#### 操作
- 查询

## 实体：参与方

- 说明：跨域引用 Organization.Party（统一主体）

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本

### Conduct（行为声明）

#### 操作
- 查询

