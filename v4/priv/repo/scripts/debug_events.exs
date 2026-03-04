# 检查 Events.Event 和 BarcodeRule 的依赖
alias UniboBddRuntime.DataFactory

# Test Event creation
IO.puts("=== Events.Event ===")
try do
  record = DataFactory.create_record!(UniboV4.Events.Event, :create)
  IO.puts("OK: #{record.id}")
rescue
  e -> IO.puts("ERR: #{Exception.message(e) |> String.slice(0, 300)}")
end

# Test EventType creation (Event needs event_type_id)
IO.puts("\n=== Events.EventType ===")
try do
  record = DataFactory.create_record!(UniboV4.Events.EventType, :create)
  IO.puts("OK: #{record.id}")
rescue
  e -> IO.puts("ERR: #{Exception.message(e) |> String.slice(0, 300)}")
end

# Test BarcodeNomenclature
IO.puts("\n=== Barcode.BarcodeNomenclature ===")
try do
  record = DataFactory.create_record!(UniboV4.Barcode.BarcodeNomenclature, :create)
  IO.puts("OK: #{record.id}")
rescue
  e -> IO.puts("ERR: #{Exception.message(e) |> String.slice(0, 300)}")
end

# Check ensure_dependencies for BarcodeRule
IO.puts("\n=== BarcodeRule ensure_dependencies ===")
action = Ash.Resource.Info.action(UniboV4.Barcode.BarcodeRule, :create)
dep_attrs = DataFactory.ensure_dependencies!(UniboV4.Barcode.BarcodeRule, action)
IO.puts("dep_attrs: #{inspect(dep_attrs)}")

# Check ensure_dependencies for EventRegistration
IO.puts("\n=== EventRegistration ensure_dependencies ===")
action2 = Ash.Resource.Info.action(UniboV4.Events.EventRegistration, :register)
if action2 do
  dep_attrs2 = DataFactory.ensure_dependencies!(UniboV4.Events.EventRegistration, action2)
  IO.puts("dep_attrs: #{inspect(dep_attrs2)}")
else
  IO.puts("No 'register' action found, checking 'create'")
  create_action = DataFactory.find_create_action(UniboV4.Events.EventRegistration)
  IO.puts("create_action: #{inspect(create_action && create_action.name)}")
end
