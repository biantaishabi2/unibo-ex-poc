# 调查 IoT must_be_present 和 invalid_value 问题
alias UniboBddRuntime.DataFactory
alias UniboBddRuntime.AshIntrospector

resources = [
  UniboV4.IoT.IoTDevice,
  UniboV4.IoT.EventLog,
  UniboV4.IoT.CallQueue,
  UniboV4.IoT.TriggerRule,
]

Enum.each(resources, fn resource ->
  IO.puts("=== #{inspect(resource)} ===")
  action = Ash.Resource.Info.action(resource, :create) ||
    DataFactory.find_create_action(resource) |> then(fn a -> Ash.Resource.Info.action(resource, a && a.name) end)

  if is_nil(action) do
    IO.puts("  No create action!")
  else
    IO.puts("  action: #{action.name}")
    IO.puts("  accept: #{inspect(action.accept)}")

    # MR args
    Enum.each(action.changes, fn
      %{change: {Ash.Resource.Change.ManageRelationship, opts}} ->
        IO.puts("  MR: arg=#{inspect(Keyword.get(opts, :argument))} rel=#{inspect(Keyword.get(opts, :relationship))}")
      _ -> :ok
    end)

    # Present validations
    Enum.each(action.changes, fn
      %{validation: {Ash.Resource.Validation.Present, opts}} ->
        IO.puts("  Present: #{inspect(opts)}")
      _ -> :ok
    end)

    # belongs_to
    Enum.each(Ash.Resource.Info.relationships(resource), fn rel ->
      if rel.type == :belongs_to do
        IO.puts("  bt #{rel.name}: fk=#{rel.source_attribute} dest=#{inspect(rel.destination)} allow_nil?=#{rel.allow_nil?}")
      end
    end)

    # 尝试 ensure_dependencies
    try do
      dep_attrs = DataFactory.ensure_dependencies!(resource, action)
      IO.puts("  dep_attrs: #{inspect(dep_attrs)}")
    rescue
      e -> IO.puts("  ensure_deps FAIL: #{Exception.message(e) |> String.slice(0, 200)}")
    end
  end
  IO.puts("")
end)
