alias UniboV4.Generated.BddDomainRegistry
alias UniboBddRuntime.DataFactory

domains = BddDomainRegistry.domain_map()
count = 0

Enum.each(domains, fn {_domain_name, domain_mod} ->
  if count >= 5, do: throw(:done)
  try do
    resources = Ash.Domain.Info.resources(domain_mod)
    Enum.each(resources, fn resource ->
      if count >= 5, do: throw(:done)
      create_action = DataFactory.find_create_action(resource)
      if create_action do
        try do
          _record = DataFactory.create_record!(resource, create_action.name)
        rescue
          e ->
            msg = Exception.message(e)
            if String.contains?(msg, "must be present") and count < 5 do
              count = count + 1
              IO.puts("MUST_PRESENT: #{inspect(resource)}")

              # 提取 field name
              case Regex.run(~r/attribute (\w+) is required/, msg) do
                [_, field] -> IO.puts("  field: #{field}")
                _ ->
                  case Regex.run(~r/must be present.*?field: :(\w+)/, msg) do
                    [_, field] -> IO.puts("  field: #{field}")
                    _ -> :ok
                  end
              end

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
