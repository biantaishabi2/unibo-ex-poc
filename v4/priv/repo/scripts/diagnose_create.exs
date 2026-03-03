alias UniboV4.Generated.BddDomainRegistry
alias UniboBddRuntime.DataFactory

domains = BddDomainRegistry.domain_map()
results = %{ok: [], fail: [], skip: []}

results = Enum.reduce(domains, results, fn {domain_name, domain_mod}, acc ->
  try do
    resources = Ash.Domain.Info.resources(domain_mod)
    Enum.reduce(resources, acc, fn resource, acc2 ->
      actions = Ash.Resource.Info.actions(resource)
      create_action = Enum.find(actions, fn a -> a.type == :create and a.primary? end) ||
                      Enum.find(actions, fn a -> a.type == :create end)
      if is_nil(create_action) do
        %{acc2 | skip: [{domain_name, resource} | acc2.skip]}
      else
        try do
          _record = DataFactory.create_record!(resource, create_action.name)
          %{acc2 | ok: [{domain_name, resource} | acc2.ok]}
        rescue
          e ->
            %{acc2 | fail: [{domain_name, resource, Exception.message(e)} | acc2.fail]}
        end
      end
    end)
  rescue
    _ -> acc
  end
end)

IO.puts("=== Resource 创建诊断 ===")
IO.puts("OK:   #{length(results.ok)}")
IO.puts("FAIL: #{length(results.fail)}")
IO.puts("SKIP: #{length(results.skip)} (无 create action)")
IO.puts("")

if length(results.fail) > 0 do
  IO.puts("--- 失败列表 ---")
  results.fail
  |> Enum.group_by(fn {domain, _, _} -> domain end)
  |> Enum.sort()
  |> Enum.each(fn {domain, failures} ->
    IO.puts("  #{domain}:")
    Enum.each(failures, fn {_, res, msg} ->
      short = res |> Module.split() |> List.last()
      err = msg |> String.slice(0, 120)
      IO.puts("    #{short}: #{err}")
    end)
  end)
end
