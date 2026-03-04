# 诊断依赖链创建
alias UniboBddRuntime.DataFactory

# 尝试创建依赖链中的每个资源
resources = [
  {UniboV4.Documents.Folder, :create},
  {UniboV4.Documents.Facet, :create},
  {UniboV4.Documents.Tag, :create},
  {UniboV4.Documents.Document, :create},
  {UniboV4.Documents.Share, :create},
  {UniboV4.Sales.SalesOrder, :create},
  {UniboV4.Sales.SalesOrderItem, :create},
  {UniboV4.Sales.Return, :create},
  {UniboV4.Rental.RentalOrder, :create},
  {UniboV4.Purchasing.PurchaseOrder, :create},
  {UniboV4.Communication.Channel, :create},
  {UniboV4.Marketing.EventMailSchedule, :create},
  {UniboV4.Marketing.EventTypeBooth, :create},
]

Enum.each(resources, fn {resource, action_name} ->
  short = inspect(resource) |> String.replace("UniboV4.", "")
  try do
    record = DataFactory.create_record!(resource, action_name)
    IO.puts("OK  #{short}")
  rescue
    e ->
      msg = Exception.message(e) |> String.slice(0, 300)
      IO.puts("FAIL #{short}: #{msg}")
  end
end)
