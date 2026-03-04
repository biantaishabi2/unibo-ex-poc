alias UniboV4.Generated.BddDomainRegistry
alias UniboBddRuntime.DataFactory

domains = BddDomainRegistry.domain_map()
found = :counters.new(1, [])

Enum.each(domains, fn {domain_name, domain_mod} ->
  if :counters.get(found, 1) >= 5, do: throw(:done)

  try do
    resources = Ash.Domain.Info.resources(domain_mod)
    Enum.each(resources, fn resource ->
      if :counters.get(found, 1) >= 5, do: throw(:done)

      create_action = DataFactory.find_create_action(resource)
      if create_action do
        try do
          _record = DataFactory.create_record!(resource, create_action.name)
        rescue
          e ->
            msg = Exception.message(e)
            if String.contains?(msg, "Required{field:") do
              :counters.add(found, 1, 1)
              action = Ash.Resource.Info.action(resource, create_action.name)
              IO.puts("---FAIL: #{inspect(resource)} action=#{create_action.name}---")
              Enum.each(action.arguments, fn arg ->
                IO.puts("  arg #{arg.name}: type=#{inspect(arg.type)} allow_nil?=#{inspect(arg.allow_nil?)}")
              end)
              # 显示 belongs_to 关系
              rels = Ash.Resource.Info.relationships(resource)
              bt_rels = Enum.filter(rels, &(&1.type == :belongs_to))
              Enum.each(bt_rels, fn rel ->
                IO.puts("  bt #{rel.name}: src_attr=#{rel.source_attribute} dest=#{inspect(rel.destination)}")
              end)
              IO.puts("  err: #{msg |> String.slice(0, 300)}")
              IO.puts("")
            end
        end
      end
    end)
  catch
    :done -> :ok
  rescue
    _ -> :ok
  end
end)
