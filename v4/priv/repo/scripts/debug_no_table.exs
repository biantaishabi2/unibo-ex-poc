# 统计 no_table 失败的资源
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
            if String.contains?(msg, "undefined_table") do
              # 错误信息中引号被转义为 \"table_name\"
              table = case Regex.run(~r/relation \\?"([^"\\]+)\\?" does not exist/, msg) do
                [_, t] -> t
                _ ->
                  case Regex.run(~r/relation .(.+?). does not exist/, msg) do
                    [_, t] -> String.replace(t, "\"", "")
                    _ -> "?"
                  end
              end
              [{domain_name, inspect(resource), table} | acc2]
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

IO.puts("=== Missing tables (#{length(results)}) ===")
results
|> Enum.sort()
|> Enum.each(fn {domain, _resource, table} ->
  IO.puts("#{domain}: #{table}")
end)

# 统计唯一表名
tables = results |> Enum.map(fn {_, _, t} -> t end) |> Enum.uniq() |> Enum.sort()
IO.puts("\nUnique missing tables (#{length(tables)}):")
Enum.each(tables, &IO.puts("  #{&1}"))
