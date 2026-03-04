# 诊断剩余失败的资源
IO.puts("=== EventTypeBooth ===")
res = UniboV4.Marketing.EventTypeBooth
Enum.each(Ash.Resource.Info.relationships(res), fn rel ->
  if rel.type == :belongs_to, do: IO.puts("  bt: #{rel.name} fk=#{rel.source_attribute}")
end)
attr = Enum.find(Ash.Resource.Info.attributes(res), &(&1.name == :event_type_id))
if attr do
  IO.puts("  event_type_id: allow_nil?=#{attr.allow_nil?}")
else
  IO.puts("  event_type_id: NOT an attribute")
end

IO.puts("")
IO.puts("=== TimesheetEntry ===")
res2 = UniboV4.Project.TimesheetEntry
Enum.each(Ash.Resource.Info.relationships(res2), fn rel ->
  if rel.type == :belongs_to, do: IO.puts("  bt: #{rel.name} fk=#{rel.source_attribute}")
end)
attr2 = Enum.find(Ash.Resource.Info.attributes(res2), &(&1.name == :project_analytic_account_id))
if attr2 do
  IO.puts("  project_analytic_account_id: allow_nil?=#{attr2.allow_nil?}, type=#{inspect(attr2.type)}")
else
  IO.puts("  project_analytic_account_id: NOT an attribute")
end

IO.puts("")
IO.puts("=== SubscriptionOrderLine ===")
res3 = UniboV4.Subscriptions.SubscriptionOrderLine
action3 = Ash.Resource.Info.action(res3, :create)
all_attr_names = Ash.Resource.Info.attributes(res3) |> Enum.map(& &1.name)
accept_not_in_attrs = (action3.accept || []) -- all_attr_names
IO.puts("  accept not in attrs: #{inspect(accept_not_in_attrs)}")

IO.puts("")
IO.puts("=== Spreadsheet.Revision ===")
res4 = UniboV4.Spreadsheet.Revision
action4 = Ash.Resource.Info.action(res4, :apply_revision)
arg = Enum.find(action4.arguments || [], &(&1.name == :user_id))
if arg do
  IO.puts("  user_id arg: type=#{inspect(arg.type)} allow_nil?=#{arg.allow_nil?}")
end
Enum.each(Ash.Resource.Info.relationships(res4), fn rel ->
  if rel.type == :belongs_to, do: IO.puts("  bt: #{rel.name} → #{inspect(rel.destination)} fk=#{rel.source_attribute}")
end)

IO.puts("")
IO.puts("=== Documents.Share upload_via_share ===")
res5 = UniboV4.Documents.Share
action5 = Ash.Resource.Info.action(res5, :upload_via_share)
Enum.each(action5.changes || [], fn
  %{validation: {Ash.Resource.Validation.Present, opts}} ->
    IO.puts("  present: #{inspect(opts)}")
  _ -> :ok
end)
Enum.each(action5.arguments || [], fn arg ->
  IO.puts("  arg: #{arg.name} type=#{inspect(arg.type)} allow_nil?=#{arg.allow_nil?}")
end)
