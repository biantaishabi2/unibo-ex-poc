# 检查 collect_mr_required_uuid_fks 是否工作
resource = UniboV4.Inventory.StockPickingItem
action = Ash.Resource.Info.action(resource, :create)

# 手动调用内部逻辑
mr_changes = (action.changes || [])
|> Enum.flat_map(fn
  %{change: {Ash.Resource.Change.ManageRelationship, opts}} ->
    arg_name = Keyword.get(opts, :argument)
    rel_name = Keyword.get(opts, :relationship) || Keyword.get(opts, :relationship_name)
    mr_opts = Keyword.get(opts, :opts, [])
    if arg_name && rel_name, do: [{arg_name, rel_name, mr_opts}], else: []
  _ -> []
end)

IO.puts("MR changes: #{inspect(mr_changes)}")

bt_rels = UniboBddRuntime.AshIntrospector.belongs_to_relationships(resource)
IO.puts("BT rels: #{inspect(Enum.map(bt_rels, &{&1.name, &1.source_attribute}))}")

args = action.arguments || []
IO.puts("Args: #{inspect(Enum.map(args, &{&1.name, &1.type, &1.allow_nil?}))}")

# 手动计算 mr_required_fks
result = Enum.reduce(mr_changes, %{}, fn {arg_name, rel_name, _mr_opts}, acc ->
  arg = Enum.find(args, &(&1.name == arg_name))
  IO.puts("Checking MR #{arg_name}: arg=#{inspect(arg && arg.name)} type=#{inspect(arg && arg.type)} allow_nil?=#{inspect(arg && arg.allow_nil?)}")

  if arg do
    type_name = cond do
      arg.type == Ash.Type.UUID -> :uuid
      true -> :other
    end
    IO.puts("  type_name: #{inspect(type_name)}")

    if type_name == :uuid and not arg.allow_nil? do
      rel = Enum.find(bt_rels, &(&1.name == rel_name))
      IO.puts("  Found bt rel: #{inspect(rel && {rel.name, rel.source_attribute})}")
      if rel, do: Map.put(acc, rel.source_attribute, arg_name), else: acc
    else
      acc
    end
  else
    acc
  end
end)

IO.puts("\nmr_required_fks: #{inspect(result)}")

# 测试 ensure_dependencies! 输出
IO.puts("\n=== Testing ensure_dependencies! ===")
dep_attrs = UniboBddRuntime.DataFactory.ensure_dependencies!(resource, action)
IO.puts("dep_attrs: #{inspect(dep_attrs)}")
