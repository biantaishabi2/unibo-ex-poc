# 诊断自引用问题
alias UniboBddRuntime.DataFactory

res = UniboV4.Documents.Document
action = Ash.Resource.Info.action(res, :create)

IO.puts("=== 尝试 ensure_dependencies! ===")
try do
  deps = DataFactory.ensure_dependencies!(res, action)
  IO.puts("deps: #{inspect(deps)}")
rescue
  e ->
    IO.puts("ERROR: #{Exception.message(e) |> String.slice(0, 500)}")
    IO.puts("TRACE:")
    __STACKTRACE__ |> Enum.take(8) |> Enum.each(&IO.puts("  #{inspect(&1)}"))
end

IO.puts("\n=== 尝试直接 Ash.create authorize?:false ===")
try do
  domain = Ash.Resource.Info.domain(res)
  input = %{name: "test_folder", type: :folder}
  cs = Ash.Changeset.for_create(res, :create, input, domain: domain, authorize?: false)
  # 清除所有错误
  cs = %{cs | errors: [], valid?: true}
  case Ash.create(cs) do
    {:ok, r} -> IO.puts("OK: id=#{r.id}")
    {:error, err} -> IO.puts("FAIL: #{inspect(err) |> String.slice(0, 500)}")
  end
rescue
  e -> IO.puts("CRASH: #{Exception.message(e) |> String.slice(0, 300)}")
end
