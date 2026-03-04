# 详细分析剩余失败 — 只列资源名和简短错误
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
            # 提取关键错误信息
            short = cond do
              msg =~ "must be present" ->
                case Regex.run(~r/field: :(\w+).*must be present/, msg) do
                  [_, field] -> "must_be_present: #{field}"
                  _ -> "must_be_present: ?"
                end
              msg =~ "is required" ->
                case Regex.run(~r/field: :(\w+).*is required/, msg) do
                  [_, field] -> "required: #{field}"
                  _ -> "required: ?"
                end
              msg =~ "Required" ->
                case Regex.run(~r/Required\{field: :(\w+), type: :(\w+)/, msg) do
                  [_, field, type] -> "required_#{type}: #{field}"
                  _ -> "required: ?"
                end
              msg =~ "NoSuchInput" ->
                case Regex.run(~r/input: :(\w+)/, msg) do
                  [_, input] -> "no_such_input: #{input}"
                  _ -> "no_such_input: ?"
                end
              msg =~ "Forbidden" -> "forbidden"
              msg =~ "Invalid reference" ->
                case Regex.run(~r/Invalid reference (\w+)/, msg) do
                  [_, ref] -> "invalid_ref: #{ref}"
                  _ -> "invalid_ref: ?"
                end
              msg =~ "key :type not found in: nil" -> "relate_actor_nil_rel"
              msg =~ "must be greater than" ->
                case Regex.run(~r/field: :(\w+).*must be greater/, msg) do
                  [_, field] -> "comparison: #{field}"
                  _ -> "comparison: ?"
                end
              msg =~ "is invalid" ->
                case Regex.run(~r/field: :(\w+).*is invalid.*value: (.{1,20})/, msg) do
                  [_, field, val] -> "invalid_value: #{field}=#{val}"
                  _ ->
                    case Regex.run(~r/field: :(\w+).*is invalid/, msg) do
                      [_, field] -> "invalid_value: #{field}"
                      _ -> "invalid: ?"
                    end
                end
              msg =~ "Decimal" -> "decimal_error"
              msg =~ "does not exist" ->
                case Regex.run(~r/field: :(\w+).*does not exist/, msg) do
                  [_, field] -> "not_exists: #{field}"
                  _ -> "not_exists: ?"
                end
              msg =~ "expected one of" ->
                case Regex.run(~r/field: :(\w+).*expected one of/, msg) do
                  [_, field] -> "bad_enum: #{field}"
                  _ -> "bad_enum: ?"
                end
              msg =~ "NoSuchAttribute" ->
                case Regex.run(~r/attribute: :(\w+)/, msg) do
                  [_, attr] -> "no_such_attr: #{attr}"
                  _ -> "no_such_attr: ?"
                end
              true -> "other: #{String.slice(msg, 0, 100)}"
            end
            [{domain_name, inspect(resource), short} | acc2]
        end
      end
    end)
  rescue
    _ -> acc
  end
end)

# 按错误类型分组
grouped = results |> Enum.group_by(fn {_, _, short} ->
  short |> String.split(":") |> hd()
end)

Enum.sort(grouped) |> Enum.each(fn {cat, items} ->
  IO.puts("\n=== #{cat} (#{length(items)}) ===")
  items |> Enum.sort() |> Enum.each(fn {domain, resource, short} ->
    IO.puts("  #{domain}: #{resource} -> #{short}")
  end)
end)
