# 检查哪些 MR append args 没被正确处理
alias UniboV4.Generated.BddDomainRegistry
alias UniboBddRuntime.DataFactory

# 取几个典型失败案例
test_cases = [
  {UniboV4.Inventory.StockPickingItem, :create, :picking_id},
  {UniboV4.CRM.Lead, :create, :user_id},
]

Enum.each(test_cases, fn {resource, action_name, expected_arg} ->
  IO.puts("=== #{inspect(resource)} ===")
  action = Ash.Resource.Info.action(resource, action_name)

  # 检查 MR changes
  mr_changes = (action.changes || [])
  |> Enum.flat_map(fn
    %{change: {Ash.Resource.Change.ManageRelationship, opts}} ->
      [{Keyword.get(opts, :argument), Keyword.get(opts, :relationship) || Keyword.get(opts, :relationship_name), Keyword.get(opts, :opts, [])}]
    _ -> []
  end)

  IO.puts("MR changes:")
  Enum.each(mr_changes, fn {arg, rel, opts} ->
    type = Keyword.get(opts, :type)
    IO.puts("  arg=#{inspect(arg)} rel=#{inspect(rel)} type=#{inspect(type)}")
  end)

  # 检查 expected_arg 是否在 MR args 中
  in_mr = Enum.any?(mr_changes, fn {arg, _, _} -> arg == expected_arg end)
  IO.puts("#{expected_arg} in MR: #{in_mr}")

  IO.puts("")
end)

# 检查是否有些 argument 既是 MR arg 又是 required UUID
IO.puts("=== Resources with MR UUID args that fail ===")
domains = BddDomainRegistry.domain_map()
count = 0

Enum.each(domains, fn {_dn, dm} ->
  try do
    resources = Ash.Domain.Info.resources(dm)
    Enum.each(resources, fn resource ->
      create_action = DataFactory.find_create_action(resource)
      if create_action do
        action = Ash.Resource.Info.action(resource, create_action.name)
        mr_args = (action.changes || [])
        |> Enum.flat_map(fn
          %{change: {Ash.Resource.Change.ManageRelationship, opts}} ->
            arg = Keyword.get(opts, :argument)
            if arg, do: [arg], else: []
          _ -> []
        end)
        |> MapSet.new()

        # 检查哪些 required UUID args 在 MR 中
        (action.arguments || [])
        |> Enum.each(fn arg ->
          type_name = if arg.type == Ash.Type.UUID, do: :uuid, else: :other
          if type_name == :uuid and not arg.allow_nil? and MapSet.member?(mr_args, arg.name) do
            if count < 10 do
              IO.puts("  #{inspect(resource)}: #{arg.name} is MR+required UUID")
            end
          end
        end)
      end
    end)
  rescue
    _ -> :ok
  end
end)
