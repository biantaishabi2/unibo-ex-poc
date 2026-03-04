alias UniboV4.Generated.BddDomainRegistry
alias UniboBddRuntime.DataFactory

domains = BddDomainRegistry.domain_map()

fails = Enum.flat_map(domains, fn {domain_name, domain_mod} ->
  try do
    resources = Ash.Domain.Info.resources(domain_mod)
    Enum.flat_map(resources, fn resource ->
      create_action = DataFactory.find_create_action(resource)
      if is_nil(create_action) do
        []
      else
        try do
          _record = DataFactory.create_record!(resource, create_action.name)
          []
        rescue
          e ->
            msg = Exception.message(e) |> String.slice(0, 500)
            [{domain_name, resource, create_action.name, msg}]
        end
      end
    end)
  rescue
    _ -> []
  end
end)

IO.puts("=== 详细失败列表 (#{length(fails)} 个) ===\n")

Enum.each(fails, fn {dom, res, action, msg} ->
  short_name = inspect(res) |> String.replace("UniboV4.", "")
  IO.puts("--- #{dom}.#{short_name} (action: #{action}) ---")
  IO.puts(msg |> String.slice(0, 400))
  IO.puts("")
end)
