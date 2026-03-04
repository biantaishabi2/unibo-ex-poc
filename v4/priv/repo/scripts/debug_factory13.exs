# 检查所有 User 资源及其 create action
alias UniboV4.Generated.BddDomainRegistry
alias UniboBddRuntime.DataFactory

domains = BddDomainRegistry.domain_map()

IO.puts("=== User resources across domains ===")
Enum.each(domains, fn {domain_name, domain_mod} ->
  try do
    resources = Ash.Domain.Info.resources(domain_mod)
    Enum.each(resources, fn res ->
      res_name = res |> Module.split() |> List.last()
      if res_name == "User" do
        create_action = DataFactory.find_create_action(res)
        IO.puts("#{domain_name}: #{inspect(res)} create=#{inspect(create_action && create_action.name)}")
      end
    end)
  rescue
    _ -> :ok
  end
end)
