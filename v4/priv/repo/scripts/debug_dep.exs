# 检查 Delivery.Shipment 的 ensure_dependencies 为什么没设置 shipment_type_id
alias UniboBddRuntime.DataFactory

resource = UniboV4.Delivery.Shipment
action = Ash.Resource.Info.action(resource, :create)

# 检查 ShipmentType 能否创建
IO.puts("=== ShipmentType ===")
st = UniboV4.Delivery.ShipmentType
st_action = DataFactory.find_create_action(st)
IO.puts("create action: #{inspect(st_action && st_action.name)}")
if st_action do
  try do
    record = DataFactory.create_record!(st, st_action.name)
    IO.puts("OK: #{inspect(record.id)}")
  rescue
    e -> IO.puts("FAIL: #{Exception.message(e) |> String.slice(0, 200)}")
  end
end

# 检查 Facility 能否创建
IO.puts("\n=== Delivery.Facility ===")
if Code.ensure_loaded?(UniboV4.Delivery.Facility) do
  fac_action = DataFactory.find_create_action(UniboV4.Delivery.Facility)
  IO.puts("create action: #{inspect(fac_action && fac_action.name)}")
else
  IO.puts("Module not loaded!")
end

# 手动调用 ensure_dependencies
IO.puts("\n=== ensure_dependencies ===")
dep_attrs = DataFactory.ensure_dependencies!(resource, action)
IO.puts("dep_attrs: #{inspect(dep_attrs)}")
