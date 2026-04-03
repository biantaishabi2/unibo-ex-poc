# travel/priv/repo/seeds/travel_seeds.exs
# Travel 域基础数据种子（航司、舱位等级、城市、机场、车站、酒店、房型、静态码映射）
# 数据来源：旧 mock 中的真实业务数据

alias UniboExPoc.Ecommerce.{TravelCity, TravelAirport, TravelStation}
alias UniboExPoc.Travel.{TravelAirline, TravelCabinClass, TravelHotel, TravelRoomType, TravelStaticCodeMapping}
alias UniboExPoc.Travel.{FlightOffer, HotelOffer, TrainOffer}

require Ash.Query

# ── 辅助函数 ──────────────────────────────────────────────────

defmodule TravelSeeds do
  @moduledoc false

  def upsert!(resource, domain, attrs, identity, opts \\ []) do
    changeset = Ash.Changeset.for_create(resource, :create, attrs)
    create_opts = [domain: domain, upsert?: true, upsert_identity: identity] ++ opts
    case Ash.create(changeset, create_opts) do
      {:ok, record} -> record
      {:error, error} ->
        IO.puts("  ⚠ 创建 #{inspect(resource)} 失败: #{inspect(error)}")
        nil
    end
  end
end

# 默认租户
default_tenant = "default"

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

# ── 9. 航班报价（FlightOffer）─────────────────────────────────

IO.puts("\n=== 创建航班报价数据 ===")

# 种子用固定租户 ID
seed_tenant_id = "00000000-0000-0000-0000-000000000001"

flight_offers = [
  %{
    tenant_id: seed_tenant_id,
    supplier_code: "SUP_CTRIP",
    itinerary_code: "ITN_BJ_SH_001",
    flight_no: "CA1234",
    departure_airport_code: "PEK",
    arrival_airport_code: "SHA",
    departure_at: ~U[2026-04-10 08:00:00Z],
    arrival_at: ~U[2026-04-10 10:15:00Z],
    cabin_class: "经济舱",
    listed_price: Decimal.new("1200.00"),
    settlement_price: Decimal.new("980.00"),
    currency: "CNY",
    seats_available: 120,
    baggage_policy: "免费托运行李20kg",
    refund_change_policy: "起飞前2小时免费退改",
    sale_status: :active
  },
  %{
    tenant_id: seed_tenant_id,
    supplier_code: "SUP_CTRIP",
    itinerary_code: "ITN_SH_GZ_001",
    flight_no: "MU5678",
    departure_airport_code: "SHA",
    arrival_airport_code: "CAN",
    departure_at: ~U[2026-04-12 14:30:00Z],
    arrival_at: ~U[2026-04-12 17:00:00Z],
    cabin_class: "公务舱",
    listed_price: Decimal.new("3500.00"),
    settlement_price: Decimal.new("2800.00"),
    currency: "CNY",
    seats_available: 24,
    baggage_policy: "免费托运行李40kg",
    refund_change_policy: "起飞前24小时免费退改",
    sale_status: :active
  }
]

for attrs <- flight_offers do
  record = TravelSeeds.upsert!(FlightOffer, UniboExPoc.Travel, attrs, :unique_flight_offer_snapshot, tenant: seed_tenant_id)
  if record, do: IO.puts("  ✓ 航班报价: #{attrs.flight_no} #{attrs.departure_airport_code}→#{attrs.arrival_airport_code} #{attrs.cabin_class} ¥#{attrs.listed_price}")
end

# ── 10. 酒店报价（HotelOffer）────────────────────────────────

IO.puts("\n=== 创建酒店报价数据 ===")

hotel_offers = [
  %{
    tenant_id: seed_tenant_id,
    supplier_code: "SUP_CTRIP",
    hotel_code: "HTL_BJ_001",
    hotel_name: "北京国贸大酒店",
    city_code: "BJS",
    room_type_code: "RT_KING_DLX",
    rate_plan_code: "RP_STD_001",
    checkin_date: ~D[2026-04-10],
    checkout_date: ~D[2026-04-12],
    listed_price: Decimal.new("800.00"),
    settlement_price: Decimal.new("650.00"),
    currency: "CNY",
    inventory_count: 15,
    cancellation_policy: "入住前24小时免费取消",
    guarantee_policy: "信用卡担保",
    sale_status: :active
  },
  %{
    tenant_id: seed_tenant_id,
    supplier_code: "SUP_CTRIP",
    hotel_code: "HTL_SH_002",
    hotel_name: "上海外滩华尔道夫酒店",
    city_code: "SHA",
    room_type_code: "RT_SUITE_EXE",
    rate_plan_code: "RP_EXE_001",
    checkin_date: ~D[2026-04-12],
    checkout_date: ~D[2026-04-14],
    listed_price: Decimal.new("2500.00"),
    settlement_price: Decimal.new("2000.00"),
    currency: "CNY",
    inventory_count: 5,
    cancellation_policy: "不可取消",
    guarantee_policy: "全额预付",
    sale_status: :active
  }
]

for attrs <- hotel_offers do
  record = TravelSeeds.upsert!(HotelOffer, UniboExPoc.Travel, attrs, :unique_hotel_offer_snapshot, tenant: seed_tenant_id)
  if record, do: IO.puts("  ✓ 酒店报价: #{attrs.hotel_name} #{attrs.room_type_code} ¥#{attrs.listed_price}/晚")
end

# ── 11. 火车票报价（TrainOffer）───────────────────────────────

IO.puts("\n=== 创建火车票报价数据 ===")

train_offers = [
  %{
    tenant_id: seed_tenant_id,
    supplier_code: "SUP_12306",
    train_no: "G1",
    departure_station_code: "BJP",
    departure_station_name: "北京南站",
    arrival_station_code: "SHH",
    arrival_station_name: "上海虹桥站",
    travel_date: ~D[2026-04-10],
    departure_at: ~U[2026-04-10 09:00:00Z],
    arrival_at: ~U[2026-04-10 13:28:00Z],
    seat_class: "二等座",
    seat_code: "SC_2ND",
    is_no_seat: false,
    inventory_status: :available,
    waitlist_supported: true,
    listed_price: Decimal.new("553.00"),
    settlement_price: Decimal.new("553.00"),
    currency: "CNY",
    booking_rules_snapshot: "提前30天预售",
    change_rules_snapshot: "开车前48小时免费改签一次",
    refund_rules_snapshot: "开车前15天以上免费退票",
    sale_status: :active
  },
  %{
    tenant_id: seed_tenant_id,
    supplier_code: "SUP_12306",
    train_no: "G7382",
    departure_station_code: "HZD",
    departure_station_name: "杭州东站",
    arrival_station_code: "NJN",
    arrival_station_name: "南京南站",
    travel_date: ~D[2026-04-11],
    departure_at: ~U[2026-04-11 10:30:00Z],
    arrival_at: ~U[2026-04-11 11:48:00Z],
    seat_class: "一等座",
    seat_code: "SC_1ST",
    is_no_seat: false,
    inventory_status: :available,
    waitlist_supported: false,
    listed_price: Decimal.new("284.00"),
    settlement_price: Decimal.new("284.00"),
    currency: "CNY",
    booking_rules_snapshot: "提前30天预售",
    change_rules_snapshot: "开车前48小时免费改签一次",
    refund_rules_snapshot: "开车前15天以上免费退票",
    sale_status: :active
  }
]

for attrs <- train_offers do
  record = TravelSeeds.upsert!(TrainOffer, UniboExPoc.Travel, attrs, :unique_train_offer_snapshot, tenant: seed_tenant_id)
  if record, do: IO.puts("  ✓ 火车票报价: #{attrs.train_no} #{attrs.departure_station_name}→#{attrs.arrival_station_name} #{attrs.seat_class} ¥#{attrs.listed_price}")
end

IO.puts("\n=== Travel 种子数据创建完成 ===")
