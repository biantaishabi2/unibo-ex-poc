# 测试自引用 Ecto 插入 - 带完整错误追踪
res = UniboV4.Documents.Document
repo = UniboV4.Repo

attrs = %{
  id: Ash.UUID.generate(),
  name: "test_parent_folder",
  type: :folder
}

IO.puts("Testing Ecto insert...")
try do
  struct = struct(res, attrs)
  IO.puts("Struct created: #{inspect(struct.__struct__)}")
  changeset = Ecto.Changeset.change(struct, attrs)
  IO.puts("Changeset valid?: #{changeset.valid?}")
  IO.puts("Changeset changes: #{inspect(changeset.changes)}")

  case repo.insert(changeset) do
    {:ok, r} -> IO.puts("OK: id=#{r.id}")
    {:error, err} -> IO.puts("FAIL: #{inspect(err) |> String.slice(0, 500)}")
  end
rescue
  e ->
    IO.puts("CRASH: #{Exception.message(e) |> String.slice(0, 500)}")
    IO.puts("TRACE:")
    __STACKTRACE__ |> Enum.take(5) |> Enum.each(&IO.puts("  #{inspect(&1)}"))
end
