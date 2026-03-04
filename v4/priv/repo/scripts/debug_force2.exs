# 测试不同方式设置 FK 值
alias UniboBddRuntime.DataFactory

resource = UniboV4.Delivery.Shipment
domain = Ash.Resource.Info.domain(resource)
st = DataFactory.create_record!(UniboV4.Delivery.ShipmentType, :create)
IO.puts("ShipmentType: #{st.id}")

# 方案3: skip_unknown_inputs
IO.puts("\n=== 方案3: skip_unknown_inputs ===")
try do
  attrs = DataFactory.build_attrs(resource, :create)
    |> Map.put(:shipment_type_id, st.id)
  changeset = Ash.Changeset.for_create(resource, :create, attrs,
    domain: domain,
    skip_unknown_inputs: [:shipment_type_id])
  IO.puts("errors: #{inspect(changeset.errors |> Enum.map(& &1.message))}")
  IO.puts("shipment_type_id: #{inspect(Ash.Changeset.get_attribute(changeset, :shipment_type_id))}")
rescue
  e -> IO.puts("ERROR: #{Exception.message(e) |> String.slice(0, 200)}")
end

# 方案4: force_change 后清除过期错误
IO.puts("\n=== 方案4: clear stale errors ===")
try do
  attrs = DataFactory.build_attrs(resource, :create)
  changeset = Ash.Changeset.for_create(resource, :create, attrs, domain: domain)
  changeset = Ash.Changeset.force_change_attribute(changeset, :shipment_type_id, st.id)

  # 清除已设值属性的 "must be present" 错误
  cleaned_errors = Enum.reject(changeset.errors, fn
    %{field: field, message: "must be present"} ->
      Ash.Changeset.get_attribute(changeset, field) != nil
    _ -> false
  end)
  changeset = %{changeset | errors: cleaned_errors, valid?: cleaned_errors == []}
  IO.puts("cleaned errors: #{inspect(cleaned_errors |> Enum.map(& &1.message))}")
  IO.puts("shipment_type_id: #{inspect(Ash.Changeset.get_attribute(changeset, :shipment_type_id))}")

  case Ash.create(changeset) do
    {:ok, record} -> IO.puts("OK: #{record.id}")
    {:error, e} -> IO.puts("CREATE ERROR: #{inspect(e) |> String.slice(0, 300)}")
  end
rescue
  e -> IO.puts("ERROR: #{Exception.message(e) |> String.slice(0, 200)}")
end
