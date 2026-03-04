# 测试 actor 创建
resource = UniboV4.Sales.SalesOrder
action = Ash.Resource.Info.action(resource, :create)

IO.puts("=== SalesOrder actor debug ===")

# 检查 relate_actor change
Enum.each(action.changes, fn
  %{change: {Ash.Resource.Change.RelateActor, opts}} ->
    rel_name = Keyword.get(opts, :relationship)
    IO.puts("RelateActor: relationship=#{inspect(rel_name)}")
    rel = Enum.find(Ash.Resource.Info.relationships(resource), &(&1.name == rel_name))
    if rel do
      IO.puts("  dest=#{inspect(rel.destination)}")
      # 尝试创建 dest
      create_action = UniboBddRuntime.DataFactory.find_create_action(rel.destination)
      IO.puts("  create_action=#{inspect(create_action && create_action.name)}")

      if create_action do
        try do
          record = UniboBddRuntime.DataFactory.create_record!(rel.destination, create_action.name)
          IO.puts("  Created actor: #{record.id}")
        rescue
          e -> IO.puts("  Actor creation FAILED: #{Exception.message(e) |> String.slice(0, 300)}")
        end
      end
    end
  _ -> :ok
end)

# 检查 authorizers
IO.puts("\nAuthorizers: #{inspect(Ash.Resource.Info.authorizers(resource))}")

# 尝试 find_fallback_actor
IO.puts("\n=== Fallback actor ===")
# 直接找 User 资源试试
try do
  record = UniboBddRuntime.DataFactory.create_record!(UniboV4.Sales.User, :create)
  IO.puts("Sales.User created: #{record.id}")
rescue
  e -> IO.puts("Sales.User FAILED: #{Exception.message(e) |> String.slice(0, 200)}")
end
