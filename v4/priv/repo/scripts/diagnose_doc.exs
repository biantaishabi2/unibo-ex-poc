# 诊断 Documents.Document 的自引用问题
alias UniboBddRuntime.DataFactory

res = UniboV4.Documents.Document
action = Ash.Resource.Info.action(res, :create)

IO.puts("=== Document belongs_to ===")
Enum.each(Ash.Resource.Info.relationships(res), fn rel ->
  if rel.type == :belongs_to do
    IO.puts("  #{rel.name} → #{inspect(rel.destination)}, fk=#{rel.source_attribute}, allow_nil?=#{rel.allow_nil?}")
    IO.puts("    dest == resource? #{rel.destination == res}")
  end
end)

IO.puts("\n=== present validations ===")
Enum.each(action.changes || [], fn
  %{validation: {Ash.Resource.Validation.Present, opts}} ->
    IO.puts("  present: #{inspect(opts)}")
  _ -> :ok
end)

IO.puts("\n=== 尝试 ensure_dependencies! ===")
try do
  deps = DataFactory.ensure_dependencies!(res, action)
  IO.puts("deps: #{inspect(deps)}")
rescue
  e -> IO.puts("ERROR: #{Exception.message(e) |> String.slice(0, 300)}")
end
