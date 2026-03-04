# 详细检查 picking_id 在 build_argument_values 中的处理路径
resource = UniboV4.Inventory.StockPickingItem
action = Ash.Resource.Info.action(resource, :create)

# 检查 manage_relationship changes
mr_changes = (action.changes || [])
|> Enum.flat_map(fn
  %{change: {Ash.Resource.Change.ManageRelationship, opts}} ->
    arg_name = Keyword.get(opts, :argument)
    rel_name = Keyword.get(opts, :relationship) || Keyword.get(opts, :relationship_name)
    mr_opts = Keyword.get(opts, :opts, [])
    IO.puts("MR change: arg=#{inspect(arg_name)} rel=#{inspect(rel_name)} opts=#{inspect(mr_opts)}")
    if arg_name && rel_name, do: [{arg_name, rel_name, mr_opts}], else: []
  _ ->
    []
end)

mr_arg_names = mr_changes |> Enum.map(fn {arg_name, _, _} -> arg_name end) |> MapSet.new()
IO.puts("\nmr_arg_names: #{inspect(MapSet.to_list(mr_arg_names))}")

IO.puts("\nArguments and their handling:")
Enum.each(action.arguments, fn arg ->
  in_mr = MapSet.member?(mr_arg_names, arg.name)
  IO.puts("  #{arg.name}: in_mr=#{in_mr} allow_nil?=#{arg.allow_nil?} type=#{inspect(arg.type)}")
end)
