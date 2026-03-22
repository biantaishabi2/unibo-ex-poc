# travel/priv/repo/seeds/travel_seeds.exs
# Travel 域基础数据种子（航司、舱位等级、城市、机场、车站、酒店、房型、静态码映射）
# 数据来源：旧 mock 中的真实业务数据

alias UniboExPoc.Ecommerce.{TravelCity, TravelAirport, TravelStation}
alias UniboExPoc.Travel.{TravelAirline, TravelCabinClass, TravelHotel, TravelRoomType, TravelStaticCodeMapping}

require Ash.Query

# ── 辅助函数 ──────────────────────────────────────────────────

defmodule TravelSeeds do
  @moduledoc false

  def upsert!(resource, domain, attrs, identity) do
    changeset = Ash.Changeset.for_create(resource, :create, attrs)
    case Ash.create(changeset, domain: domain, upsert?: true, upsert_identity: identity) do
      {:ok, record} -> record
      {:error, error} ->
        IO.puts("  ⚠ 创建 #{inspect(resource)} 失败: #{inspect(error)}")
        nil
    end
  end
end

# ── 1. 航司（TravelAirline）──────────────────────────────────

IO.puts("=== 创建航司数据 ===")

airlines = [
  %{airline_code: "AIR_CA", airline_name: "中国国际航空", iata_code: "CA", icao_code: "CCA", status: :active},
  %{airline_code: "AIR_MU", airline_name: "中国东方航空", iata_code: "MU", icao_code: "CES", status: :active},
  %{airline_code: "AIR_CZ", airline_name: "中国南方航空", iata_code: "CZ", icao_code: "CSN", status: :active}
]

for attrs <- airlines do
  record = TravelSeeds.upsert!(TravelAirline, UniboExPoc.Travel, attrs, :unique_airline_code)
  if record, do: IO.puts("  ✓ 航司: #{attrs.airline_name} (#{attrs.iata_code})")
end

# ── 2. 舱位等级（TravelCabinClass）───────────────────────────

IO.puts("\n=== 创建舱位等级数据 ===")

cabin_classes = [
  %{cabin_class_code: "CC_Y", cabin_class_name: "经济舱", cabin_rank: 3, status: :active},
  %{cabin_class_code: "CC_C", cabin_class_name: "公务舱", cabin_rank: 2, status: :active},
  %{cabin_class_code: "CC_F", cabin_class_name: "头等舱", cabin_rank: 1, status: :active}
]

for attrs <- cabin_classes do
  record = TravelSeeds.upsert!(TravelCabinClass, UniboExPoc.Travel, attrs, :unique_cabin_class_code)
  if record, do: IO.puts("  ✓ 舱位: #{attrs.cabin_class_name} (#{attrs.cabin_class_code})")
end

# ── 3. 城市（TravelCity, Ecommerce 域）───────────────────────

IO.puts("\n=== 创建城市数据 ===")

cities = [
  %{city_code: "BJS", city_name: "北京", country_code: "CN", status: :active},
  %{city_code: "SHA", city_name: "上海", country_code: "CN", status: :active},
  %{city_code: "CAN", city_name: "广州", country_code: "CN", status: :active},
  %{city_code: "HGH", city_name: "杭州", country_code: "CN", status: :active},
  %{city_code: "SYX", city_name: "三亚", country_code: "CN", status: :active}
]

city_records =
  for attrs <- cities, into: %{} do
    record = TravelSeeds.upsert!(TravelCity, UniboExPoc.Ecommerce, attrs, :unique_city_code)
    if record, do: IO.puts("  ✓ 城市: #{attrs.city_name} (#{attrs.city_code})")
    {attrs.city_code, record}
  end

# ── 4. 机场（TravelAirport, Ecommerce 域）────────────────────

IO.puts("\n=== 创建机场数据 ===")

airports = [
  %{airport_code: "PEK", airport_name: "北京首都国际机场", city_code: "BJS", iata_code: "PEK", status: :active},
  %{airport_code: "PKX", airport_name: "北京大兴国际机场", city_code: "BJS", iata_code: "PKX", status: :active},
  %{airport_code: "SHA", airport_name: "上海虹桥国际机场", city_code: "SHA", iata_code: "SHA", status: :active},
  %{airport_code: "PVG", airport_name: "上海浦东国际机场", city_code: "SHA", iata_code: "PVG", status: :active},
  %{airport_code: "CAN", airport_name: "广州白云国际机场", city_code: "CAN", iata_code: "CAN", status: :active}
]

for attrs <- airports do
  city = Map.get(city_records, attrs.city_code)
  full_attrs = if city, do: Map.put(attrs, :city_id, city.id), else: attrs
  record = TravelSeeds.upsert!(TravelAirport, UniboExPoc.Ecommerce, full_attrs, :unique_airport_code)
  if record, do: IO.puts("  ✓ 机场: #{attrs.airport_name} (#{attrs.airport_code})")
end

# ── 5. 火车站（TravelStation, Ecommerce 域）──────────────────

IO.puts("\n=== 创建火车站数据 ===")

stations = [
  %{station_code: "BJP", station_name: "北京南站", city_code: "BJS", status: :active},
  %{station_code: "SHH", station_name: "上海虹桥站", city_code: "SHA", status: :active},
  %{station_code: "HZD", station_name: "杭州东站", city_code: "HGH", status: :active},
  %{station_code: "NJN", station_name: "南京南站", city_code: "BJS", status: :active}
]

for attrs <- stations do
  city = Map.get(city_records, attrs.city_code)
  full_attrs = if city, do: Map.put(attrs, :city_id, city.id), else: attrs
  record = TravelSeeds.upsert!(TravelStation, UniboExPoc.Ecommerce, full_attrs, :unique_station_code)
  if record, do: IO.puts("  ✓ 车站: #{attrs.station_name} (#{attrs.station_code})")
end

# ── 6. 酒店（TravelHotel）────────────────────────────────────

IO.puts("\n=== 创建酒店数据 ===")

hotels = [
  %{hotel_code: "HTL_BJ_001", hotel_name: "北京国贸大酒店", city_code: "BJS", hotel_star: "五星级", status: :active},
  %{hotel_code: "HTL_SH_002", hotel_name: "上海外滩华尔道夫酒店", city_code: "SHA", hotel_star: "五星级", status: :active},
  %{hotel_code: "HTL_GZ_003", hotel_name: "广州白天鹅宾馆", city_code: "CAN", hotel_star: "五星级", status: :active}
]

hotel_records =
  for attrs <- hotels, into: %{} do
    city = Map.get(city_records, attrs.city_code)
    full_attrs = if city, do: Map.put(attrs, :city_id, city.id), else: attrs
    record = TravelSeeds.upsert!(TravelHotel, UniboExPoc.Travel, full_attrs, :unique_hotel_code)
    if record, do: IO.puts("  ✓ 酒店: #{attrs.hotel_name} (#{attrs.hotel_code})")
    {attrs.hotel_code, record}
  end

# ── 7. 房型（TravelRoomType）──────────────────────────────────

IO.puts("\n=== 创建房型数据 ===")

room_types = [
  %{room_type_code: "RT_KING_DLX", room_type_name: "高级大床房", hotel_code: "HTL_BJ_001", bed_type: "大床 1.8m", status: :active},
  %{room_type_code: "RT_TWIN_STD", room_type_name: "商务双床房", hotel_code: "HTL_BJ_001", bed_type: "双床 1.2m×2", status: :active},
  %{room_type_code: "RT_SUITE_EXE", room_type_name: "行政套房", hotel_code: "HTL_SH_002", bed_type: "大床 2.0m", status: :active}
]

for attrs <- room_types do
  hotel = Map.get(hotel_records, attrs.hotel_code)
  full_attrs = if hotel, do: Map.put(attrs, :hotel_id, hotel.id), else: attrs
  record = TravelSeeds.upsert!(TravelRoomType, UniboExPoc.Travel, full_attrs, :unique_room_type_code)
  if record, do: IO.puts("  ✓ 房型: #{attrs.room_type_name} (#{attrs.room_type_code})")
end

# ── 8. 静态码映射（TravelStaticCodeMapping）──────────────────

IO.puts("\n=== 创建静态码映射数据 ===")

# 需要先查找已创建的实体 ID
# 这里用占位 UUID，实际运行时会通过 upsert 关联
placeholder_id = "00000000-0000-0000-0000-000000000001"

static_mappings = [
  # 携程 - 机场映射
  %{supplier_code: "SUP_CTRIP", object_type: :airport, canonical_entity: "Travel.Airport", canonical_id: placeholder_id, external_code: "PEK", external_name: "北京首都国际机场", status: :active},
  # 携程 - 航司映射
  %{supplier_code: "SUP_CTRIP", object_type: :airline, canonical_entity: "Travel.Airline", canonical_id: placeholder_id, external_code: "CA", external_name: "中国国际航空", status: :active},
  # 12306 - 车站映射
  %{supplier_code: "SUP_12306", object_type: :station, canonical_entity: "Travel.Station", canonical_id: placeholder_id, external_code: "BJP", external_name: "北京南站", status: :active}
]

for attrs <- static_mappings do
  record = TravelSeeds.upsert!(TravelStaticCodeMapping, UniboExPoc.Travel, attrs, :unique_supplier_static_code)
  if record, do: IO.puts("  ✓ 映射: #{attrs.supplier_code}/#{attrs.object_type}/#{attrs.external_code}")
end

IO.puts("\n=== Travel 种子数据创建完成 ===")
