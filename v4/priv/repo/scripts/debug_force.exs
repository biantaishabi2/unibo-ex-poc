# 测试 force_change_attribute 是否能满足 validate present
alias UniboBddRuntime.DataFactory

resource = UniboV4.Delivery.Shipment
action = Ash.Resource.Info.action(resource, :create)
domain = Ash.Resource.Info.domain(resource)

# 先创建 ShipmentType
st = DataFactory.create_record!(UniboV4.Delivery.ShipmentType, :create)
IO.puts("ShipmentType: #{st.id}")

# 方案1: 直接传 attrs（包含 shipment_type_id）
IO.puts("\n=== 方案1: 传入 attrs ===")
attrs = DataFactory.build_attrs(resource, :create)
  |> Map.put(:shipment_type_id, st.id)
IO.puts("attrs keys: #{inspect(Map.keys(attrs))}")
try do
  changeset = Ash.Changeset.for_create(resource, :create, attrs, domain: domain)
  IO.puts("changeset errors after for_create: #{inspect(changeset.errors)}")
  IO.puts("changeset valid?: #{changeset.valid?}")
rescue
  e -> IO.puts("for_create error: #{Exception.message(e) |> String.slice(0, 200)}")
end

# 方案2: force_change 后检查
IO.puts("\n=== 方案2: force_change ===")
try do
  attrs2 = DataFactory.build_attrs(resource, :create)
  changeset2 = Ash.Changeset.for_create(resource, :create, attrs2, domain: domain)
  IO.puts("before force: errors=#{inspect(changeset2.errors)}")
  changeset2 = Ash.Changeset.force_change_attribute(changeset2, :shipment_type_id, st.id)
  IO.puts("after force: shipment_type_id=#{inspect(Ash.Changeset.get_attribute(changeset2, :shipment_type_id))}")
  IO.puts("after force: errors=#{inspect(changeset2.errors)}")
  case Ash.create(changeset2) do
    {:ok, record} -> IO.puts("OK: #{record.id}")
    {:error, e} -> IO.puts("CREATE ERROR: #{inspect(e) |> String.slice(0, 300)}")
  end
rescue
  e -> IO.puts("ERROR: #{Exception.message(e) |> String.slice(0, 200)}")
end
