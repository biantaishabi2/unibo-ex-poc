# 测试自引用 Ecto 插入
res = UniboV4.Documents.Document
repo = UniboV4.Repo

# 检查 generate_by_ash_type 是否公开
IO.puts("generate_by_ash_type exported? #{function_exported?(UniboBddRuntime.DataFactory, :generate_by_ash_type, 3)}")

# 手动构建属性
attrs = %{
  id: Ash.UUID.generate(),
  name: "test_parent_folder",
  type: :folder
}

IO.puts("attrs: #{inspect(attrs)}")
struct = struct(res, attrs)
changeset = Ecto.Changeset.change(struct, attrs)

case repo.insert(changeset) do
  {:ok, r} -> IO.puts("OK: id=#{r.id}")
  {:error, err} -> IO.puts("FAIL: #{inspect(err) |> String.slice(0, 300)}")
end
