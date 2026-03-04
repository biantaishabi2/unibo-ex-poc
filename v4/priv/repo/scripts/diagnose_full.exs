# 完整诊断：列出每个失败资源和错误详情
alias UniboBddRuntime.DataFactory

domains = Application.get_env(:unibo_v4, :ash_domains, [])

results =
  Enum.flat_map(domains, fn domain ->
    Ash.Domain.Info.resources(domain)
    |> Enum.flat_map(fn resource ->
      Ash.Resource.Info.actions(resource)
      |> Enum.filter(&(&1.type == :create))
      |> Enum.map(fn action ->
        short = inspect(resource) |> String.replace("UniboV4.", "")
        try do
          _record = DataFactory.create_record!(resource, action.name)
          {:ok, short, action.name}
        rescue
          e ->
            msg = Exception.message(e) |> String.slice(0, 500)
            {:fail, short, action.name, msg}
        end
      end)
    end)
  end)

ok_count = Enum.count(results, &(elem(&1, 0) == :ok))
fail_list = Enum.filter(results, &(elem(&1, 0) == :fail))

IO.puts("OK: #{ok_count}")
IO.puts("FAIL: #{length(fail_list)}\n")

Enum.each(fail_list, fn {:fail, short, action, msg} ->
  IO.puts("FAIL #{short} (#{action})")
  IO.puts("  #{msg}\n")
end)
