# 诊断 must_be_present 和 required_field 的具体原因
alias UniboBddRuntime.DataFactory
alias UniboBddRuntime.AshIntrospector

resources = [
  {UniboV4.Documents.Tag, :create},
  {UniboV4.Documents.Facet, :create},
  {UniboV4.Sales.SalesOrderItem, :create},
  {UniboV4.Sales.Return, :create},
  {UniboV4.Marketing.EventTypeBooth, :create},
  {UniboV4.Communication.Channel, :create},
  {UniboV4.Marketing.EventMailSchedule, :create},
  {UniboV4.Documents.Document, :create},
  {UniboV4.Documents.Share, :create},
]

Enum.each(resources, fn {resource, action_name} ->
  action = Ash.Resource.Info.action(resource, action_name)
  short = inspect(resource) |> String.replace("UniboV4.", "")
  IO.puts("\n=== #{short} (#{action_name}) ===")
  IO.puts("  accept: #{inspect(action.accept)}")

  # validations
  Enum.each(action.changes || [], fn
    %{validation: {mod, opts}} when mod != nil ->
      IO.puts("  validation: #{inspect(mod)} #{inspect(opts)}")
    _ -> :ok
  end)

  # arguments
  Enum.each(action.arguments || [], fn arg ->
    IO.puts("  arg: #{arg.name} type=#{inspect(arg.type)} allow_nil?=#{arg.allow_nil?}")
  end)

  # belongs_to
  Enum.each(Ash.Resource.Info.relationships(resource), fn rel ->
    if rel.type == :belongs_to do
      IO.puts("  bt: #{rel.name} fk=#{rel.source_attribute} allow_nil?=#{rel.allow_nil?}")
    end
  end)

  # 尝试 DataFactory
  try do
    dep = DataFactory.ensure_dependencies!(resource, action)
    IO.puts("  dep_attrs: #{inspect(Map.keys(dep))}")
  rescue
    e -> IO.puts("  ensure_deps FAIL: #{Exception.message(e) |> String.slice(0, 200)}")
  end
end)
