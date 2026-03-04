# 测试直接插入 User 资源
resource = UniboV4.Sales.User

# 检查 User 资源的属性
IO.puts("=== Sales.User attributes ===")
Enum.each(Ash.Resource.Info.attributes(resource), fn attr ->
  IO.puts("  #{attr.name}: type=#{inspect(attr.type)} allow_nil?=#{attr.allow_nil?} primary_key?=#{attr.primary_key?} default=#{inspect(attr.default)}")
end)

IO.puts("\n=== Sales.User actions ===")
Enum.each(Ash.Resource.Info.actions(resource), fn action ->
  IO.puts("  #{action.name}: type=#{action.type}")
end)

# 直接通过 Ash Changeset 创建（不经过 action）
IO.puts("\n=== Try Ash.Changeset.for_create with simple changeset ===")
try do
  domain = Ash.Resource.Info.domain(resource)
  # 用 Ecto 直接插入
  changeset = Ecto.Changeset.change(%UniboV4.Sales.User{}, %{id: Ash.UUID.generate()})
  result = UniboV4.Repo.insert(changeset)
  IO.inspect(result, label: "Ecto insert result")
rescue
  e -> IO.puts("Ecto insert FAILED: #{Exception.message(e) |> String.slice(0, 300)}")
end
