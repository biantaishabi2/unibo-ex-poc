# 诊断 ensure_dependencies! 为何返回空
alias UniboBddRuntime.DataFactory

res = UniboV4.Documents.Document
action = Ash.Resource.Info.action(res, :create)
accepted = action.accept || []

IO.puts("accepted: #{inspect(accepted)}")

bt_rels = Ash.Resource.Info.relationships(res) |> Enum.filter(&(&1.type == :belongs_to))
IO.puts("bt_rels count: #{length(bt_rels)}")

# 模拟 ensure_dependencies! 逻辑
Enum.each(bt_rels, fn rel ->
  fk_attr = rel.source_attribute
  IO.puts("\nrel: #{rel.name}, fk=#{fk_attr}, allow_nil?=#{rel.allow_nil?}, dest=#{inspect(rel.destination)}")
  IO.puts("  fk_attr in accepted? #{fk_attr in accepted}")
  IO.puts("  not allow_nil? #{not rel.allow_nil?}")
  IO.puts("  dest == res? #{rel.destination == res}")
  IO.puts("  Code.ensure_loaded? #{Code.ensure_loaded?(rel.destination)}")
end)

# 直接测试 seed_self_referencing 思路
IO.puts("\n=== 尝试直接 Ecto 插入 ===")
try do
  repo = UniboV4.Repo
  attrs = %{
    id: Ash.UUID.generate(),
    name: "test_parent",
    type: "folder"
  }
  struct = struct(res, attrs)
  changeset = Ecto.Changeset.change(struct, attrs)
  case repo.insert(changeset) do
    {:ok, record} -> IO.puts("OK: id=#{record.id}")
    {:error, err} -> IO.puts("FAIL: #{inspect(err)}")
  end
rescue
  e -> IO.puts("ERROR: #{Exception.message(e) |> String.slice(0, 300)}")
end
