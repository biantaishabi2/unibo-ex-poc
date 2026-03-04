# 诊断每种失败的具体原因
alias UniboBddRuntime.DataFactory
alias UniboBddRuntime.AshIntrospector

# 1. IoT 域: 检查 argument 类型和 MR 配置
IO.puts("=== IoT Domain ===")
resources = [
  {UniboV4.IoT.IoTDevice, :upsert},
  {UniboV4.IoT.VoIPProvider, :create},
  {UniboV4.IoT.QueueMember, :create},
]

Enum.each(resources, fn {resource, action_name} ->
  action = Ash.Resource.Info.action(resource, action_name)
  IO.puts("\n#{inspect(resource)} (#{action_name}):")
  IO.puts("  accept: #{inspect(action.accept)}")

  # arguments
  Enum.each(action.arguments, fn arg ->
    IO.puts("  arg: #{arg.name} type=#{inspect(arg.type)} allow_nil?=#{arg.allow_nil?}")
  end)

  # MR changes
  Enum.each(action.changes, fn
    %{change: {Ash.Resource.Change.ManageRelationship, opts}} ->
      IO.puts("  MR: arg=#{inspect(Keyword.get(opts, :argument))} rel=#{inspect(Keyword.get(opts, :relationship))} opts=#{inspect(Keyword.get(opts, :opts, []))}")
    _ -> :ok
  end)

  # belongs_to
  Enum.each(Ash.Resource.Info.relationships(resource), fn rel ->
    if rel.type == :belongs_to do
      IO.puts("  bt: #{rel.name} fk=#{rel.source_attribute} dest=#{inspect(rel.destination)} allow_nil?=#{rel.allow_nil?}")
    end
  end)

  # PK of resource
  pk = Ash.Resource.Info.primary_key(resource)
  pk_attrs = Enum.map(pk, fn name ->
    attr = Enum.find(Ash.Resource.Info.attributes(resource), &(&1.name == name))
    {name, attr && attr.type}
  end)
  IO.puts("  PK: #{inspect(pk_attrs)}")
end)

# 2. Rating: 检查 compare validation
IO.puts("\n\n=== Rating ===")
action = Ash.Resource.Info.action(UniboV4.Rating.Rating, :submit)
IO.puts("action: submit")
IO.puts("accept: #{inspect(action.accept)}")
Enum.each(action.arguments, fn arg ->
  IO.puts("  arg: #{arg.name} type=#{inspect(arg.type)}")
end)
Enum.each(action.changes, fn
  %{validation: v} when v != nil -> IO.puts("  validation: #{inspect(v)}")
  _ -> :ok
end)

# 3. Lunch.LunchTopping: 检查 topping_category 类型
IO.puts("\n\n=== Lunch.LunchTopping ===")
resource = UniboV4.Lunch.LunchTopping
action = Ash.Resource.Info.action(resource, :create)
IO.puts("accept: #{inspect(action.accept)}")
attr = Enum.find(Ash.Resource.Info.attributes(resource), &(&1.name == :topping_category))
IO.puts("topping_category type=#{inspect(attr.type)} constraints=#{inspect(attr.constraints)}")
if Code.ensure_loaded?(attr.type) and function_exported?(attr.type, :values, 0) do
  IO.puts("  enum values: #{inspect(attr.type.values())}")
end

# 4. Communication.Channel: group_public_id
IO.puts("\n\n=== Communication.Channel ===")
resource = UniboV4.Communication.Channel
action = Ash.Resource.Info.action(resource, :create)
IO.puts("accept: #{inspect(action.accept)}")
Enum.each(action.arguments, fn arg ->
  IO.puts("  arg: #{arg.name} type=#{inspect(arg.type)} allow_nil?=#{arg.allow_nil?}")
end)
attr = Enum.find(Ash.Resource.Info.attributes(resource), &(&1.name == :group_public_id))
IO.puts("group_public_id type=#{inspect(attr && attr.type)} constraints=#{inspect(attr && attr.constraints)}")

# 5. Marketing.EventMailSchedule: interval_unit
IO.puts("\n\n=== Marketing.EventMailSchedule ===")
resource = UniboV4.Marketing.EventMailSchedule
action = Ash.Resource.Info.action(resource, :create)
attr = Enum.find(Ash.Resource.Info.attributes(resource), &(&1.name == :interval_unit))
IO.puts("interval_unit type=#{inspect(attr && attr.type)} constraints=#{inspect(attr && attr.constraints)}")
if attr && Code.ensure_loaded?(attr.type) and function_exported?(attr.type, :values, 0) do
  IO.puts("  enum values: #{inspect(attr.type.values())}")
end
