# 检查 required_argument 失败案例的 MR 和 belongs_to 配置
resources = [
  {UniboV4.Purchasing.GoodsReceiptItem, :create, :receipt_id},
  {UniboV4.Purchasing.PurchaseOrderItem, :create, :order_id},
  {UniboV4.Sales.SalesOrderItem, :create, :order_id},
  {UniboV4.Approvals.Approver, :create, :request_id},
  {UniboV4.Spreadsheet.DataSource, :create, :document_id},
]

Enum.each(resources, fn {resource, action_name, arg_name} ->
  IO.puts("=== #{inspect(resource)} ===")
  action = Ash.Resource.Info.action(resource, action_name)

  # 检查 arg
  arg = Enum.find(action.arguments, &(&1.name == arg_name))
  IO.puts("  arg: #{arg_name} type=#{inspect(arg && arg.type)} allow_nil?=#{inspect(arg && arg.allow_nil?)}")

  # 检查 MR
  mr = Enum.find(action.changes, fn
    %{change: {Ash.Resource.Change.ManageRelationship, opts}} ->
      Keyword.get(opts, :argument) == arg_name
    _ -> false
  end)
  if mr do
    %{change: {_, opts}} = mr
    IO.puts("  MR: rel=#{inspect(Keyword.get(opts, :relationship))} opts=#{inspect(Keyword.get(opts, :opts, []))}")
  else
    IO.puts("  MR: none")
  end

  # 检查 belongs_to
  bt = Ash.Resource.Info.relationships(resource)
    |> Enum.filter(&(&1.type == :belongs_to))
  IO.puts("  belongs_to:")
  Enum.each(bt, fn rel ->
    IO.puts("    #{rel.name}: fk=#{rel.source_attribute} dest=#{inspect(rel.destination)}")
  end)
  IO.puts("")
end)
