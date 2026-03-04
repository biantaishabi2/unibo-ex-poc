# 检查 SalesOrderItem 依赖
resource = UniboV4.Sales.SalesOrderItem
action = Ash.Resource.Info.action(resource, :create)

# MR changes
mr_changes = (action.changes || [])
|> Enum.flat_map(fn
  %{change: {Ash.Resource.Change.ManageRelationship, opts}} ->
    [{Keyword.get(opts, :argument), Keyword.get(opts, :relationship) || Keyword.get(opts, :relationship_name), Keyword.get(opts, :opts, [])}]
  _ -> []
end)
IO.puts("MR changes:")
Enum.each(mr_changes, fn {arg, rel, opts} -> IO.puts("  #{arg} -> #{rel} type=#{inspect(Keyword.get(opts, :type))}") end)

# BT rels
bt_rels = UniboBddRuntime.AshIntrospector.belongs_to_relationships(resource)
IO.puts("BT rels:")
Enum.each(bt_rels, fn rel -> IO.puts("  #{rel.name}: src=#{rel.source_attribute} dest=#{inspect(rel.destination)}") end)

# Args
IO.puts("Args:")
Enum.each(action.arguments, fn arg ->
  IO.puts("  #{arg.name}: type=#{inspect(arg.type)} allow_nil?=#{arg.allow_nil?}")
end)

# 测试 SalesOrder 创建
IO.puts("\n=== Testing SalesOrder creation ===")
try do
  record = UniboBddRuntime.DataFactory.create_record!(UniboV4.Sales.SalesOrder, :create)
  IO.puts("OK: #{record.id}")
rescue
  e -> IO.puts("ERR: #{Exception.message(e) |> String.slice(0, 300)}")
end

# 测试 dep_attrs
IO.puts("\n=== ensure_dependencies! ===")
dep_attrs = UniboBddRuntime.DataFactory.ensure_dependencies!(resource, action)
IO.puts("dep_attrs: #{inspect(dep_attrs)}")
