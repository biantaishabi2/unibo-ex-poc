# 诊断 required_field 剩余失败
alias UniboV4.Generated.BddDomainRegistry
alias UniboBddRuntime.DataFactory

domains = BddDomainRegistry.domain_map()

results = Enum.reduce(domains, %{}, fn {_domain_name, domain_mod}, acc ->
  try do
    resources = Ash.Domain.Info.resources(domain_mod)
    Enum.reduce(resources, acc, fn resource, acc2 ->
      create_action = DataFactory.find_create_action(resource)
      if is_nil(create_action) do
        acc2
      else
        try do
          _record = DataFactory.create_record!(resource, create_action.name)
          acc2
        rescue
          e ->
            msg = Exception.message(e)
            if String.contains?(msg, "Required{field:") do
              case Regex.run(~r/Required\{field: :(\w+), type: :(\w+)/, msg) do
                [_, field, type] ->
                  key = "#{type}:#{field}"
                  Map.update(acc2, key, 1, &(&1 + 1))
                _ ->
                  Map.update(acc2, "unknown", 1, &(&1 + 1))
              end
            else
              acc2
            end
        end
      end
    end)
  rescue
    _ -> acc
  end
end)

IO.puts("=== Required field failures by field ===")
results
|> Enum.sort_by(fn {_, n} -> -n end)
|> Enum.each(fn {key, n} ->
  IO.puts("  #{key}: #{n}")
end)
