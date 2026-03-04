alias UniboV4.Generated.BddDomainRegistry
alias UniboBddRuntime.DataFactory

domains = BddDomainRegistry.domain_map()
results = %{ok: [], fail: []}

results = Enum.reduce(domains, results, fn {domain_name, domain_mod}, acc ->
  try do
    resources = Ash.Domain.Info.resources(domain_mod)
    Enum.reduce(resources, acc, fn resource, acc2 ->
      create_action = DataFactory.find_create_action(resource)
      if is_nil(create_action) do
        acc2
      else
        try do
          _record = DataFactory.create_record!(resource, create_action.name)
          %{acc2 | ok: [{domain_name, resource} | acc2.ok]}
        rescue
          e ->
            msg = Exception.message(e)
            cat = cond do
              String.contains?(msg, "Could not determine domain") -> :no_domain
              String.contains?(msg, "must be present") -> :must_be_present
              String.contains?(msg, "undefined_table") -> :no_table
              String.contains?(msg, "NotFound") -> :not_found
              String.contains?(msg, "Forbidden") -> :forbidden
              String.contains?(msg, "relate to actor") -> :actor_missing
              String.contains?(msg, "Required{field:") -> :required_field
              true -> :other
            end
            %{acc2 | fail: [{domain_name, resource, cat, msg} | acc2.fail]}
        end
      end
    end)
  rescue
    _ -> acc
  end
end)

IO.puts("=== Resource 创建诊断 v2 ===")
IO.puts("OK:   #{length(results.ok)}")
IO.puts("FAIL: #{length(results.fail)}")

cats = Enum.reduce(results.fail, %{}, fn {_, _, cat, _}, acc ->
  Map.update(acc, cat, 1, &(&1 + 1))
end)
IO.puts("\nFail categories:")
Enum.sort_by(cats, fn {_, n} -> -n end) |> Enum.each(fn {cat, n} ->
  IO.puts("  #{cat}: #{n}")
end)
