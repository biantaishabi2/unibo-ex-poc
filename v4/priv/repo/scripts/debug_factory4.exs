# 测试 StockPicking 本身是否能创建
alias UniboBddRuntime.DataFactory

IO.puts("=== Testing StockPicking creation ===")
resource = UniboV4.Inventory.StockPicking
create_action = DataFactory.find_create_action(resource)
IO.puts("Action: #{create_action.name}")

try do
  record = DataFactory.create_record!(resource, create_action.name)
  IO.puts("OK: #{record.id}")
rescue
  e ->
    IO.puts("ERR: #{Exception.message(e) |> String.slice(0, 500)}")
end

IO.puts("\n=== Testing Warehouse creation ===")
resource2 = UniboV4.Inventory.Warehouse
create_action2 = DataFactory.find_create_action(resource2)
IO.puts("Action: #{create_action2.name}")

try do
  record = DataFactory.create_record!(resource2, create_action2.name)
  IO.puts("OK: #{record.id}")
rescue
  e ->
    IO.puts("ERR: #{Exception.message(e) |> String.slice(0, 500)}")
end

IO.puts("\n=== Testing StockLocation creation ===")
resource3 = UniboV4.Inventory.StockLocation
create_action3 = DataFactory.find_create_action(resource3)
IO.puts("Action: #{create_action3.name}")

try do
  record = DataFactory.create_record!(resource3, create_action3.name)
  IO.puts("OK: #{record.id}")
rescue
  e ->
    IO.puts("ERR: #{Exception.message(e) |> String.slice(0, 500)}")
end
