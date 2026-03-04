# 完整测试 StockPickingItem 创建
alias UniboBddRuntime.DataFactory

IO.puts("=== Testing StockPickingItem full creation ===")
resource = UniboV4.Inventory.StockPickingItem
try do
  record = DataFactory.create_record!(resource, :create)
  IO.puts("OK: #{record.id}")
rescue
  e ->
    IO.puts("ERR: #{Exception.message(e) |> String.slice(0, 500)}")
end

IO.puts("\n=== Testing SalesOrderItem full creation ===")
resource2 = UniboV4.Sales.SalesOrderItem
try do
  record = DataFactory.create_record!(resource2, :create)
  IO.puts("OK: #{record.id}")
rescue
  e ->
    IO.puts("ERR: #{Exception.message(e) |> String.slice(0, 500)}")
end

IO.puts("\n=== Testing CRM Lead full creation ===")
resource3 = UniboV4.CRM.Lead
try do
  record = DataFactory.create_record!(resource3, :create)
  IO.puts("OK: #{record.id}")
rescue
  e ->
    IO.puts("ERR: #{Exception.message(e) |> String.slice(0, 500)}")
end
