# 统计有多少资源存在 "required attr not in accept" 的情况
alias UniboV4.Generated.BddDomainRegistry
alias UniboBddRuntime.DataFactory

domains = BddDomainRegistry.domain_map()
count = 0

Enum.each(domains, fn {_domain_name, domain_mod} ->
  try do
    resources = Ash.Domain.Info.resources(domain_mod)
    Enum.each(resources, fn resource ->
      create_action = DataFactory.find_create_action(resource)
      if create_action do
        accepted = create_action.accept || []
        all_attrs = Ash.Resource.Info.attributes(resource)

        required_not_accepted = Enum.filter(all_attrs, fn attr ->
          not attr.allow_nil? and
          is_nil(attr.default) and
          attr.name not in [:id, :inserted_at, :updated_at] and
          not attr.primary_key? and
          attr.name not in accepted
        end)

        if length(required_not_accepted) > 0 do
          names = Enum.map(required_not_accepted, & &1.name)
          IO.puts("#{inspect(resource)}: required_not_accepted=#{inspect(names)}")
        end
      end
    end)
  rescue
    _ -> :ok
  end
end)
