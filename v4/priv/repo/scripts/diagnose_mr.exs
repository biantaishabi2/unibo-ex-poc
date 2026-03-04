# 诊断 MR 相关的 present validation 问题
alias UniboBddRuntime.DataFactory

resources = [
  {UniboV4.Sales.SalesOrder, :create},
  {UniboV4.Purchasing.PurchaseOrder, :create},
  {UniboV4.Rental.RentalOrder, :create},
  {UniboV4.Forum.Post, :create},
  {UniboV4.Marketing.EventTypeBooth, :create},
  {UniboV4.Project.TimesheetEntry, :create},
  {UniboV4.Lunch.LunchTopping, :create},
  {UniboV4.Marketing.EventMailSchedule, :create},
  {UniboV4.Spreadsheet.Revision, :apply_revision},
  {UniboV4.Subscriptions.SubscriptionOrderLine, :create},
]

Enum.each(resources, fn {res, act_name} ->
  action = Ash.Resource.Info.action(res, act_name)
  short = inspect(res) |> String.replace("UniboV4.", "")
  IO.puts("\n=== #{short} (#{act_name}) ===")

  # arguments
  Enum.each(action.arguments || [], fn arg ->
    IO.puts("  arg: #{arg.name} type=#{inspect(arg.type)} allow_nil?=#{arg.allow_nil?}")
  end)

  # present validations
  Enum.each(action.changes || [], fn
    %{validation: {Ash.Resource.Validation.Present, opts}} ->
      IO.puts("  present: #{inspect(opts)}")
    %{change: {Ash.Resource.Change.ManageRelationship, opts}} ->
      arg = Keyword.get(opts, :argument)
      rel = Keyword.get(opts, :relationship) || Keyword.get(opts, :relationship_name)
      mr_opts = Keyword.get(opts, :opts, [])
      type = Keyword.get(mr_opts, :type)
      IO.puts("  MR: arg=#{arg} rel=#{rel} type=#{type}")
    _ -> :ok
  end)

  # belongs_to
  Enum.each(Ash.Resource.Info.relationships(res), fn rel ->
    if rel.type == :belongs_to do
      IO.puts("  bt: #{rel.name} → #{inspect(rel.destination)} fk=#{rel.source_attribute} allow_nil?=#{rel.allow_nil?}")
    end
  end)
end)
