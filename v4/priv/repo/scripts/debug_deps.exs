# 手动跟踪 Facet 的依赖创建过程
alias UniboBddRuntime.DataFactory
alias UniboBddRuntime.AshIntrospector

resource = UniboV4.Documents.Facet
action = Ash.Resource.Info.action(resource, :create)

IO.puts("=== 手动跟踪 Facet 依赖 ===")

# 1. 检查 ensure_dependencies
dep_attrs = DataFactory.ensure_dependencies!(resource, action)
IO.puts("dep_attrs: #{inspect(dep_attrs)}")

# 2. 手动创建 Folder
IO.puts("\n手动创建 Folder:")
try do
  folder = DataFactory.create_record!(UniboV4.Documents.Folder, :create)
  IO.puts("Folder OK: id=#{inspect(folder.id)}")

  # 3. 手动用 folder_id 创建 Facet
  IO.puts("\n用 folder_id 创建 Facet:")
  facet = DataFactory.create_record!(resource, :create, overrides: %{folder_id: folder.id})
  IO.puts("Facet OK: id=#{inspect(facet.id)}")
rescue
  e ->
    IO.puts("FAIL: #{Exception.message(e) |> String.slice(0, 300)}")
    IO.puts("Stacktrace:")
    __STACKTRACE__ |> Enum.take(5) |> Enum.each(&IO.puts("  #{inspect(&1)}"))
end

# 4. 检查 Facet 的 MR 配置
IO.puts("\n=== Facet action changes ===")
Enum.each(action.changes || [], fn
  %{change: {mod, opts}} when mod != nil ->
    IO.puts("  change: #{inspect(mod)} #{inspect(opts)}")
  %{validation: {mod, opts}} when mod != nil ->
    IO.puts("  validation: #{inspect(mod)} #{inspect(opts)}")
  _ -> :ok
end)
