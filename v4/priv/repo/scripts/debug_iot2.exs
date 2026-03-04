# 测试 IoTDevice 创建的实际错误
alias UniboBddRuntime.DataFactory

IO.puts("=== Try create IoTBox ===")
try do
  box = DataFactory.create_record!(UniboV4.IoT.IoTBox, :create)
  IO.puts("IoTBox OK: id=#{inspect(box.id)} type=#{inspect(box.id.__struct__ || :primitive)}")
rescue
  e -> IO.puts("IoTBox FAIL: #{Exception.message(e) |> String.slice(0, 300)}")
end

IO.puts("\n=== Try create IoTDevice ===")
try do
  device = DataFactory.create_record!(UniboV4.IoT.IoTDevice, :upsert)
  IO.puts("IoTDevice OK: #{inspect(device.id)}")
rescue
  e -> IO.puts("IoTDevice FAIL: #{Exception.message(e) |> String.slice(0, 400)}")
end

IO.puts("\n=== Try create CallQueue ===")
try do
  queue = DataFactory.create_record!(UniboV4.IoT.CallQueue, :create)
  IO.puts("CallQueue OK: #{inspect(queue.id)}")
rescue
  e -> IO.puts("CallQueue FAIL: #{Exception.message(e) |> String.slice(0, 400)}")
end
