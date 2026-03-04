# 详细分析剩余失败
alias UniboV4.Generated.BddDomainRegistry
alias UniboBddRuntime.DataFactory

domains = BddDomainRegistry.domain_map()

results = Enum.reduce(domains, [], fn {domain_name, domain_mod}, acc ->
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
            short = String.slice(msg, 0, 300)
            [{domain_name, inspect(resource), short} | acc2]
        end
      end
    end)
  rescue
    _ -> acc
  end
end)

# 按错误类型分组
grouped = Enum.group_by(results, fn {_, _, msg} ->
  cond do
    String.contains?(msg, "must be present") -> :must_be_present
    String.contains?(msg, "is required") -> :required_field
    String.contains?(msg, "Forbidden") -> :forbidden
    String.contains?(msg, "NoSuchInput") -> :no_such_input
    String.contains?(msg, "not_found") or String.contains?(msg, "NotFound") -> :not_found
    String.contains?(msg, "undefined_table") -> :no_table
    true -> :other
  end
end)

Enum.each(grouped, fn {category, items} ->
  IO.puts("\n=== #{category} (#{length(items)}) ===")
  Enum.each(items, fn {domain, resource, msg} ->
    IO.puts("#{domain}: #{resource}")
    IO.puts("  #{msg}")
    IO.puts("")
  end)
end)
