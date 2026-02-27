---
name: ash-usage-guardrails
description: 在 Elixir/Ash 项目中按官方 usage-rules 修复和实现 Resource/Domain/GraphQL 代码。用于处理 DSL 编译错误、manage_relationship、primary action、GraphQL 暴露与测试补齐。
---

# Ash Usage Guardrails

## 何时使用

当任务满足任一条件时使用本 skill：

- 修改 `use Ash.Resource` / `use Ash.Domain` 相关模块
- 出现 Ash DSL 编译错误（如 validation 函数名不匹配、缺失 primary action）
- 使用 `manage_relationship` 管理关联
- 需要把 Ash 资源暴露到 GraphQL（`ash_graphql` + `Absinthe`）
- 需要为 Ash 资源补测试（资源层/GraphQL 层）

## 最小执行流程

1. 先做基线检查
- 运行 `mix compile`
- 记录第一条编译错误（不要盲改多处）

2. 定位官方约束
- 优先查本地 `deps/ash/usage-rules/*.md`
- 再查实现定义：`deps/ash/lib/ash/**`
- 优先用 `rg` 检索关键字（如 `attribute_does_not_equal`、`primary_action`、`manage_relationship`）

3. 修 DSL，再回归编译
- 每次只修一类错误，修后立刻 `mix compile`
- 编译通过后再做迁移/测试

4. 最后补测试
- 至少覆盖：成功路径 + 关键边界失败路径

## 高优先级规则

### 1) Validation Builtins 名称以版本为准

常见错误：写成 `attribute_not_equals/2`。

在 Ash 3.x 中，应使用：

- `attribute_does_not_equal/2`
- `attribute_equals/2`
- `attribute_in/2`

不要凭记忆写函数名，先在 `Ash.Resource.Validation.Builtins` 中确认。

### 2) `manage_relationship` 依赖 primary action

只要用了：

- `on_no_match: :create`
- `on_match: :update`
- `on_missing: :destroy` / `:unrelate`

就必须保证目标 resource 存在对应 **primary** action。

若报 `Required primary create/update/destroy action`：

- 在目标 resource 的 `actions do` 中给对应 action 加 `primary? true`
- 或减少 `manage_relationship` 需要的动作类型

### 3) GraphQL 挂载需要 Schema 入口模块

如果 router 里有：

- `forward "/graphql", Absinthe.Plug, schema: XxxWeb.Schema`

则必须存在 `XxxWeb.Schema`，并通过 `use AshGraphql, domains: [...]` 绑定 domain。

### 4) 改完 DSL 先编译，再迁移

顺序固定：

1. `mix compile`
2. `mix ash_postgres.generate_migrations`
3. `mix ecto.migrate`
4. `mix test`

## 推荐命令模板

```bash
# 1) 基线
mix compile

# 2) 快速定位 Ash 约束
rg -n "attribute_does_not_equal|primary_action|manage_relationship" deps/ash -S

# 3) 数据层与测试
mix ash_postgres.generate_migrations
mix ecto.migrate
mix test
```

## 输出要求

提交实现说明时至少包含：

- 触发错误（原始报错摘要）
- 根因（对应 usage-rule/源码约束）
- 修改点（文件与关键动作）
- 验证结果（compile/migrate/test）

## 参考资料

- [Ash DSL 检查清单](references/ash-dsl-checklist.md)
