# Ash DSL 检查清单

## A. 编译错误排查顺序

1. `mix compile` 获取第一条错误
2. 错误点定位到具体 resource/action
3. 在 `deps/ash/usage-rules` 找规则
4. 在 `deps/ash/lib/ash` 找实际函数/行为
5. 最小改动修复
6. 再次 `mix compile`

## B. 常见错误 -> 处理

### 1) undefined function `attribute_not_equals/2`

- 原因：函数名与当前 Ash 版本不匹配
- 处理：改为 `attribute_does_not_equal/2`

### 2) Required primary create/update/destroy action

- 原因：`manage_relationship` 触发了对应动作需求
- 处理：给目标 resource 对应 action 设置 `primary? true`

示例：

```elixir
actions do
  create :create do
    primary? true
    # ...
  end

  update :update do
    primary? true
    # ...
  end
end
```

### 3) GraphQL schema module missing

- 原因：router forward 指向不存在模块
- 处理：新增 `Web.Schema` 并绑定 domain

示例：

```elixir
defmodule MyAppWeb.Schema do
  use Absinthe.Schema
  use AshGraphql, domains: [MyApp.Domain]
end
```

## C. 资源定义核对

- `use Ash.Resource` 是否包含正确 `domain` 与 `data_layer`
- `postgres do` 是否声明 `table` 与 `repo`
- `actions do` 是否覆盖业务所需动作
- 使用 `manage_relationship` 时，关联两侧动作是否可达
- `graphql do` 的 mutation/query 是否指向存在动作

## D. 回归验证清单

- `mix compile` 通过
- `mix ash_postgres.generate_migrations` 成功
- `mix ecto.migrate` 成功
- `mix test` 至少覆盖成功路径 + 一个失败边界
