# 检查实际错误消息格式
alias UniboBddRuntime.DataFactory

resources = [UniboV4.Barcode.BarcodeNomenclature, UniboV4.Events.EventType, UniboV4.Fleet.Driver]

Enum.each(resources, fn resource ->
  IO.puts("=== #{inspect(resource)} ===")
  create_action = DataFactory.find_create_action(resource)
  if create_action do
    try do
      DataFactory.create_record!(resource, create_action.name)
    rescue
      e ->
        IO.puts("Error class: #{inspect(e.__struct__)}")
        IO.puts("Message: #{Exception.message(e) |> String.slice(0, 500)}")
        IO.puts("")
    end
  else
    IO.puts("No create action\n")
  end
end)
