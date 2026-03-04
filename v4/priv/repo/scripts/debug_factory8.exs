# 检查 not_found 错误的详情
alias UniboV4.Generated.BddDomainRegistry
alias UniboBddRuntime.DataFactory

domains = BddDomainRegistry.domain_map()
found = 0

Enum.each(domains, fn {_domain_name, domain_mod} ->
  if found >= 5, do: throw(:done)

  try do
    resources = Ash.Domain.Info.resources(domain_mod)
    Enum.each(resources, fn resource ->
      if found >= 5, do: throw(:done)

      create_action = DataFactory.find_create_action(resource)
      if create_action do
        try do
          _record = DataFactory.create_record!(resource, create_action.name)
        rescue
          e ->
            msg = Exception.message(e)
            if String.contains?(msg, "NotFound") and found < 5 do
              found = found + 1
              IO.puts("NOT_FOUND: #{inspect(resource)}")
              IO.puts("  err: #{msg |> String.slice(0, 400)}")
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
