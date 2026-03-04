# 测试 StockPickingItem 的 create 流程
alias UniboBddRuntime.DataFactory

resource = UniboV4.Inventory.StockPickingItem
action = Ash.Resource.Info.action(resource, :create)

IO.puts("=== StockPickingItem debug ===")
IO.puts("Arguments:")
Enum.each(action.arguments, fn arg ->
  IO.puts("  #{arg.name}: type=#{inspect(arg.type)} allow_nil?=#{arg.allow_nil?}")
end)

IO.puts("\nBelongs_to relationships:")
rels = Ash.Resource.Info.relationships(resource)
bt_rels = Enum.filter(rels, &(&1.type == :belongs_to))
Enum.each(bt_rels, fn rel ->
  IO.puts("  #{rel.name}: src_attr=#{rel.source_attribute} dest=#{inspect(rel.destination)} allow_nil?=#{rel.allow_nil?}")
end)

IO.puts("\nAccepted attrs: #{inspect(action.accept)}")

IO.puts("\nChanges:")
Enum.each(action.changes, fn c ->
  IO.inspect(c, limit: 3, label: "  change")
end)

# 尝试手动匹配 arg
arg = Enum.find(action.arguments, &(&1.name == :picking_id))
IO.puts("\npicking_id arg allow_nil?: #{inspect(arg.allow_nil?)}")
IO.puts("Map.get allow_nil?: #{inspect(Map.get(arg, :allow_nil?, true))}")

# 检查 infer_belongs_to_for_arg
IO.puts("\nChecking if picking_id matches a belongs_to...")
bt = Enum.find(bt_rels, fn rel -> rel.source_attribute == :picking_id end)
IO.puts("Found bt by src_attr: #{inspect(bt && bt.name)}")

# 尝试创建
IO.puts("\nAttempting create...")
try do
  record = DataFactory.create_record!(resource, :create)
  IO.puts("OK: #{record.id}")
rescue
  e ->
    IO.puts("ERR: #{Exception.message(e) |> String.slice(0, 500)}")
end
