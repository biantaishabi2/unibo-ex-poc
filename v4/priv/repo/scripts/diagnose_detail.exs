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
            msg = Exception.message(e) |> String.slice(0, 200)
            [{domain_name, resource, msg}]
        end
      end
    end)
  rescue
    _ -> []
  end
end)

Enum.each(fails, fn {dom, res, msg} ->
  IO.puts("#{dom} | #{inspect(res)} | #{msg}")
end)
IO.puts("\nTotal FAIL: #{length(fails)}")
