# priv/repo/seeds/travel_seeds.exs
# Travel 域 seed 数据 — 基于 generate-seeds 骨架 + 真实业务数据填充
# 生成命令: unibo generate-seeds --seed Travel --module-prefix UniboExPoc
# 实体顺序：基础主数据 -> Offer -> Order -> Fulfillment

alias UniboExPoc.Travel.{
  TravelAirline,
  TravelCabinClass,
  TravelHotel,
  TravelRoomType,
  TravelStaticCodeMapping,
  FlightOffer,
  HotelOffer,
  TrainOffer,
  VacationOffer,
  TravelOrder,
  TravelFulfillment
}

require Ash.Query

# ── 共享租户 ID（所有 offer/order 共用同一租户）───────────────
tenant_id = "00000000-0000-4000-a000-000000000001"

# ── 辅助函数 ──────────────────────────────────────────────────
defmodule TravelSeedHelper do
  @moduledoc false

  @doc "创建资源，重复时跳过（upsert 模式）"
  def create!(resource, domain, attrs, opts \\ []) do
    identity = Keyword.get(opts, :identity)
    action = Keyword.get(opts, :action, :create)

    changeset = Ash.Changeset.for_create(resource, action, attrs)

    create_opts =
      [domain: domain]
      |> then(fn o -> if identity, do: Keyword.merge(o, upsert?: true, upsert_identity: identity), else: o end)

    case Ash.create(changeset, create_opts) do
      {:ok, record} -> record
      {:error, error} ->
        IO.puts("  ! 创建 #{inspect(resource)} 失败: #{inspect(error)}")
        nil
    end
  end
end

IO.puts("\n========================================")
IO.puts("  Travel 域 Seed 数据")
IO.puts("========================================\n")

# ══════════════════════════════════════════════════════════════
# 第一部分：基础主数据
# ══════════════════════════════════════════════════════════════

# ── 1. 航司（TravelAirline）──────────────────────────────────

IO.puts("--- 创建航司 ---")

airline_ca = TravelSeedHelper.create!(TravelAirline, UniboExPoc.Travel, %{
  airline_code: "AIR_CA",
  airline_name: "中国国际航空",
  iata_code: "CA",
  icao_code: "CCA",
  status: :active
}, identity: :unique_airline_code)
IO.puts("  航司: 中国国际航空 (CA)")

airline_mu = TravelSeedHelper.create!(TravelAirline, UniboExPoc.Travel, %{
  airline_code: "AIR_MU",
  airline_name: "中国东方航空",
  iata_code: "MU",
  icao_code: "CES",
  status: :active
}, identity: :unique_airline_code)
IO.puts("  航司: 中国东方航空 (MU)")

airline_cz = TravelSeedHelper.create!(TravelAirline, UniboExPoc.Travel, %{
  airline_code: "AIR_CZ",
  airline_name: "中国南方航空",
  iata_code: "CZ",
  icao_code: "CSN",
  status: :active
}, identity: :unique_airline_code)
IO.puts("  航司: 中国南方航空 (CZ)")

# ── 2. 舱位等级（TravelCabinClass）───────────────────────────

IO.puts("\n--- 创建舱位等级 ---")

cabin_y = TravelSeedHelper.create!(TravelCabinClass, UniboExPoc.Travel, %{
  cabin_class_code: "CC_Y",
  cabin_class_name: "经济舱",
  cabin_rank: 3,
  status: :active
}, identity: :unique_cabin_class_code)
IO.puts("  舱位: 经济舱 (CC_Y)")

cabin_c = TravelSeedHelper.create!(TravelCabinClass, UniboExPoc.Travel, %{
  cabin_class_code: "CC_C",
  cabin_class_name: "公务舱",
  cabin_rank: 2,
  status: :active
}, identity: :unique_cabin_class_code)
IO.puts("  舱位: 公务舱 (CC_C)")

cabin_f = TravelSeedHelper.create!(TravelCabinClass, UniboExPoc.Travel, %{
  cabin_class_code: "CC_F",
  cabin_class_name: "头等舱",
  cabin_rank: 1,
  status: :active
}, identity: :unique_cabin_class_code)
IO.puts("  舱位: 头等舱 (CC_F)")

# ── 3. 酒店（TravelHotel）────────────────────────────────────

IO.puts("\n--- 创建酒店 ---")

hotel_bj = TravelSeedHelper.create!(TravelHotel, UniboExPoc.Travel, %{
  hotel_code: "HTL_BJ_001",
  hotel_name: "全季酒店（北京国贸店）",
  city_code: "BJS",
  hotel_star: "四星级",
  status: :active
}, identity: :unique_hotel_code)
IO.puts("  酒店: 全季酒店（北京国贸店）")

hotel_sh = TravelSeedHelper.create!(TravelHotel, UniboExPoc.Travel, %{
  hotel_code: "HTL_SH_001",
  hotel_name: "如家酒店（上海外滩店）",
  city_code: "SHA",
  hotel_star: "三星级",
  status: :active
}, identity: :unique_hotel_code)
IO.puts("  酒店: 如家酒店（上海外滩店）")

hotel_gz = TravelSeedHelper.create!(TravelHotel, UniboExPoc.Travel, %{
  hotel_code: "HTL_GZ_001",
  hotel_name: "汉庭酒店（广州天河店）",
  city_code: "CAN",
  hotel_star: "三星级",
  status: :active
}, identity: :unique_hotel_code)
IO.puts("  酒店: 汉庭酒店（广州天河店）")

# ── 4. 房型（TravelRoomType）──────────────────────────────────

IO.puts("\n--- 创建房型 ---")

room_bj_king = TravelSeedHelper.create!(TravelRoomType, UniboExPoc.Travel, %{
  room_type_code: "RT_BJ_KING",
  room_type_name: "高级大床房",
  hotel_code: "HTL_BJ_001",
  bed_type: "大床 1.8m",
  hotel_id: hotel_bj && hotel_bj.id,
  status: :active
}, identity: :unique_room_type_code)
IO.puts("  房型: 高级大床房 (全季北京)")

room_sh_twin = TravelSeedHelper.create!(TravelRoomType, UniboExPoc.Travel, %{
  room_type_code: "RT_SH_TWIN",
  room_type_name: "商务双床房",
  hotel_code: "HTL_SH_001",
  bed_type: "双床 1.2m x 2",
  hotel_id: hotel_sh && hotel_sh.id,
  status: :active
}, identity: :unique_room_type_code)
IO.puts("  房型: 商务双床房 (如家上海)")

room_gz_suite = TravelSeedHelper.create!(TravelRoomType, UniboExPoc.Travel, %{
  room_type_code: "RT_GZ_SUITE",
  room_type_name: "行政套房",
  hotel_code: "HTL_GZ_001",
  bed_type: "大床 2.0m",
  hotel_id: hotel_gz && hotel_gz.id,
  status: :active
}, identity: :unique_room_type_code)
IO.puts("  房型: 行政套房 (汉庭广州)")

# ── 5. 静态码映射（TravelStaticCodeMapping）──────────────────

IO.puts("\n--- 创建静态码映射 ---")

placeholder_id = Ash.UUID.generate()

for {supplier, obj_type, entity, code, name} <- [
  {"SUP_CTRIP", :airport, "Travel.Airport", "PEK", "北京首都国际机场"},
  {"SUP_CTRIP", :airline, "Travel.Airline", "CA", "中国国际航空"},
  {"SUP_12306", :station, "Travel.Station", "BJP", "北京南站"},
  {"SUP_CTRIP", :city, "Travel.City", "BJS", "北京"},
  {"SUP_QUNAR", :airport, "Travel.Airport", "SHA", "上海虹桥国际机场"}
] do
  TravelSeedHelper.create!(TravelStaticCodeMapping, UniboExPoc.Travel, %{
    supplier_code: supplier,
    object_type: obj_type,
    canonical_entity: entity,
    canonical_id: placeholder_id,
    external_code: code,
    external_name: name,
    status: :active
  }, identity: :unique_supplier_static_code)
  IO.puts("  映射: #{supplier}/#{obj_type}/#{code}")
end

# ══════════════════════════════════════════════════════════════
# 第二部分：Offer 报价数据
# ══════════════════════════════════════════════════════════════

IO.puts("\n--- 创建机票 Offer ---")

# 国航 CA1234 北京-上海 经济舱（活跃）
flight_offer_1 =
  FlightOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_CTRIP",
    itinerary_code: "ITN_BJS_SHA_001",
    flight_no: "CA1234",
    airline_ref_id: airline_ca && airline_ca.id,
    departure_airport_code: "PEK",
    arrival_airport_code: "SHA",
    departure_at: ~U[2026-04-15T08:00:00Z],
    arrival_at: ~U[2026-04-15T10:15:00Z],
    cabin_class: "经济舱",
    cabin_class_ref_id: cabin_y && cabin_y.id,
    fare_family: "标准经济",
    listed_price: Decimal.new("1280.00"),
    settlement_price: Decimal.new("980.00"),
    currency: "CNY",
    seats_available: 42,
    baggage_policy: "免费托运行李20kg，随身7kg",
    refund_change_policy: "起飞前24小时免费改签，退票收30%手续费",
    sale_status: :active
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  机票: CA1234 北京->上海 经济舱 ¥1280")

# 东航 MU5678 上海-广州 公务舱（活跃）
flight_offer_2 =
  FlightOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_CTRIP",
    itinerary_code: "ITN_SHA_CAN_001",
    flight_no: "MU5678",
    airline_ref_id: airline_mu && airline_mu.id,
    departure_airport_code: "PVG",
    arrival_airport_code: "CAN",
    departure_at: ~U[2026-04-20T14:30:00Z],
    arrival_at: ~U[2026-04-20T17:00:00Z],
    cabin_class: "公务舱",
    cabin_class_ref_id: cabin_c && cabin_c.id,
    fare_family: "超值公务",
    listed_price: Decimal.new("3560.00"),
    settlement_price: Decimal.new("2800.00"),
    currency: "CNY",
    seats_available: 8,
    baggage_policy: "免费托运行李40kg，随身10kg",
    refund_change_policy: "免费退改签",
    sale_status: :active
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  机票: MU5678 上海->广州 公务舱 ¥3560")

# 南航 CZ9012 广州-北京 经济舱（已过期）
flight_offer_3 =
  FlightOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_QUNAR",
    itinerary_code: "ITN_CAN_BJS_001",
    flight_no: "CZ9012",
    airline_ref_id: airline_cz && airline_cz.id,
    departure_airport_code: "CAN",
    arrival_airport_code: "PEK",
    departure_at: ~U[2026-03-01T20:00:00Z],
    arrival_at: ~U[2026-03-01T23:10:00Z],
    cabin_class: "经济舱",
    cabin_class_ref_id: cabin_y && cabin_y.id,
    fare_family: "特价经济",
    listed_price: Decimal.new("890.00"),
    settlement_price: Decimal.new("720.00"),
    currency: "CNY",
    seats_available: 0,
    baggage_policy: "免费托运行李20kg",
    refund_change_policy: "不可退改签",
    sale_status: :draft
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  机票: CZ9012 广州->北京 经济舱 ¥890 (草稿)")

IO.puts("\n--- 创建酒店 Offer ---")

# 全季北京国贸 高级大床房（活跃）
hotel_offer_1 =
  HotelOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_CTRIP",
    hotel_code: "HTL_BJ_001",
    hotel_ref_id: hotel_bj && hotel_bj.id,
    hotel_name: "全季酒店（北京国贸店）",
    city_code: "BJS",
    room_type_code: "RT_BJ_KING",
    room_type_ref_id: room_bj_king && room_bj_king.id,
    rate_plan_code: "RP_BJ_STANDARD",
    checkin_date: ~D[2026-04-15],
    checkout_date: ~D[2026-04-17],
    listed_price: Decimal.new("598.00"),
    settlement_price: Decimal.new("450.00"),
    currency: "CNY",
    inventory_count: 15,
    cancellation_policy: "入住前1天18:00前免费取消",
    guarantee_policy: "信用卡担保",
    sale_status: :active
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  酒店: 全季北京 大床房 ¥598/晚 (4/15-4/17)")

# 如家上海外滩 商务双床房（活跃）
hotel_offer_2 =
  HotelOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_CTRIP",
    hotel_code: "HTL_SH_001",
    hotel_ref_id: hotel_sh && hotel_sh.id,
    hotel_name: "如家酒店（上海外滩店）",
    city_code: "SHA",
    room_type_code: "RT_SH_TWIN",
    room_type_ref_id: room_sh_twin && room_sh_twin.id,
    rate_plan_code: "RP_SH_MEMBER",
    checkin_date: ~D[2026-04-20],
    checkout_date: ~D[2026-04-22],
    listed_price: Decimal.new("368.00"),
    settlement_price: Decimal.new("280.00"),
    currency: "CNY",
    inventory_count: 8,
    cancellation_policy: "入住前2天可免费取消，之后扣首晚房费",
    guarantee_policy: "预付全款",
    sale_status: :active
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  酒店: 如家上海 双床房 ¥368/晚 (4/20-4/22)")

# 汉庭广州天河 行政套房（草稿）
hotel_offer_3 =
  HotelOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_QUNAR",
    hotel_code: "HTL_GZ_001",
    hotel_ref_id: hotel_gz && hotel_gz.id,
    hotel_name: "汉庭酒店（广州天河店）",
    city_code: "CAN",
    room_type_code: "RT_GZ_SUITE",
    room_type_ref_id: room_gz_suite && room_gz_suite.id,
    rate_plan_code: "RP_GZ_PROMO",
    checkin_date: ~D[2026-05-01],
    checkout_date: ~D[2026-05-03],
    listed_price: Decimal.new("888.00"),
    settlement_price: Decimal.new("680.00"),
    currency: "CNY",
    inventory_count: 3,
    cancellation_policy: "不可取消",
    guarantee_policy: "到店付款",
    sale_status: :draft
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  酒店: 汉庭广州 套房 ¥888/晚 (5/1-5/3) (草稿)")

IO.puts("\n--- 创建火车票 Offer ---")

# 京沪高铁 G1 二等座（活跃）
train_offer_1 =
  TrainOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_12306",
    train_no: "G1",
    departure_station_code: "BJP",
    departure_station_name: "北京南站",
    arrival_station_code: "SHH",
    arrival_station_name: "上海虹桥站",
    travel_date: ~D[2026-04-15],
    departure_at: ~U[2026-04-15T09:00:00Z],
    arrival_at: ~U[2026-04-15T13:28:00Z],
    seat_class: "二等座",
    seat_code: "O",
    is_no_seat: false,
    inventory_status: :available,
    waitlist_supported: true,
    listed_price: Decimal.new("553.00"),
    settlement_price: Decimal.new("553.00"),
    currency: "CNY",
    booking_rules_snapshot: "提前30天开售，每人限购5张",
    change_rules_snapshot: "开车前48小时免费改签一次",
    refund_rules_snapshot: "开车前15天以上免手续费，15天内收5%-20%",
    sale_status: :active
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  火车票: G1 北京南->上海虹桥 二等座 ¥553")

# 沪杭动车 D3001 一等座（活跃，候补）
train_offer_2 =
  TrainOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_12306",
    train_no: "D3001",
    departure_station_code: "SHH",
    departure_station_name: "上海虹桥站",
    arrival_station_code: "HZD",
    arrival_station_name: "杭州东站",
    travel_date: ~D[2026-04-16],
    departure_at: ~U[2026-04-16T07:05:00Z],
    arrival_at: ~U[2026-04-16T08:04:00Z],
    seat_class: "一等座",
    seat_code: "M",
    is_no_seat: false,
    inventory_status: :waitlist_only,
    waitlist_supported: true,
    listed_price: Decimal.new("117.00"),
    settlement_price: Decimal.new("117.00"),
    currency: "CNY",
    booking_rules_snapshot: "提前30天开售",
    change_rules_snapshot: "开车前48小时免费改签一次",
    refund_rules_snapshot: "开车前15天以上免手续费",
    sale_status: :active
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  火车票: D3001 上海虹桥->杭州东 一等座 ¥117 (候补)")

# 京沪高铁 G3 商务座（售罄）
train_offer_3 =
  TrainOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_12306",
    train_no: "G3",
    departure_station_code: "BJP",
    departure_station_name: "北京南站",
    arrival_station_code: "SHH",
    arrival_station_name: "上海虹桥站",
    travel_date: ~D[2026-04-15],
    departure_at: ~U[2026-04-15T10:00:00Z],
    arrival_at: ~U[2026-04-15T14:28:00Z],
    seat_class: "商务座",
    seat_code: "9",
    is_no_seat: false,
    inventory_status: :sold_out,
    waitlist_supported: false,
    listed_price: Decimal.new("1748.00"),
    settlement_price: Decimal.new("1748.00"),
    currency: "CNY",
    booking_rules_snapshot: "提前30天开售",
    change_rules_snapshot: "开车前48小时免费改签一次",
    refund_rules_snapshot: "开车前15天以上免手续费",
    sale_status: :active
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  火车票: G3 北京南->上海虹桥 商务座 ¥1748 (售罄)")

IO.puts("\n--- 创建度假 Offer ---")

# 三亚 5 日游（活跃，跟团）
vacation_offer_1 =
  VacationOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_CTRIP",
    package_code: "PKG_SYX_5D",
    package_name: "三亚阳光海岸5日跟团游",
    package_type: :group_tour,
    departure_city_code: "BJS",
    destination_code: "SYX",
    start_date: ~D[2026-05-01],
    end_date: ~D[2026-05-05],
    listed_price: Decimal.new("4999.00"),
    settlement_price: Decimal.new("3800.00"),
    currency: "CNY",
    inventory_count: 20,
    booking_rules: "至少提前7天预订，2人起订",
    cancellation_policy: "出发前7天免费取消，3-7天扣30%，3天内不可取消",
    sale_status: :active
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  度假: 三亚阳光海岸5日跟团游 ¥4999")

# 云南 6 日游（活跃，自由行）
vacation_offer_2 =
  VacationOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_CTRIP",
    package_code: "PKG_KMG_6D",
    package_name: "云南大理丽江6日自由行",
    package_type: :free_travel,
    departure_city_code: "SHA",
    destination_code: "KMG",
    start_date: ~D[2026-06-10],
    end_date: ~D[2026-06-15],
    listed_price: Decimal.new("5680.00"),
    settlement_price: Decimal.new("4200.00"),
    currency: "CNY",
    inventory_count: 50,
    booking_rules: "至少提前3天预订",
    cancellation_policy: "出发前3天免费取消，之后扣50%",
    sale_status: :active
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  度假: 云南大理丽江6日自由行 ¥5680")

# 杭州西湖 3 日机酒套餐（草稿）
vacation_offer_3 =
  VacationOffer
  |> Ash.Changeset.for_create(:create, %{
    tenant_id: tenant_id,
    supplier_code: "SUP_QUNAR",
    package_code: "PKG_HGH_3D",
    package_name: "杭州西湖3日机酒套餐",
    package_type: :ticket_hotel,
    departure_city_code: "BJS",
    destination_code: "HGH",
    start_date: ~D[2026-07-01],
    end_date: ~D[2026-07-03],
    listed_price: Decimal.new("2680.00"),
    settlement_price: Decimal.new("2100.00"),
    currency: "CNY",
    inventory_count: 10,
    booking_rules: "至少提前5天预订",
    cancellation_policy: "出发前5天免费取消",
    sale_status: :draft
  })
  |> Ash.create!(domain: UniboExPoc.Travel)
IO.puts("  度假: 杭州西湖3日机酒套餐 ¥2680 (草稿)")

# ══════════════════════════════════════════════════════════════
# 第三部分：订单数据（TravelOrder）
# 注意：TravelOrder.create_order action 有复杂验证
# （customer_id 必填 + exactly 1 offer_id + 各 offer_id 都有 present 验证）
# 这里用 Repo.insert! 绕过 Ash action 验证，直接写入
# ══════════════════════════════════════════════════════════════

IO.puts("\n--- 创建旅行订单 ---")

now = DateTime.utc_now()

# 订单 1：酒店订单 - 草稿
order_hotel_id = Ash.UUID.generate()
UniboExPoc.Repo.insert_all("travel_orders", [
  %{
    id: order_hotel_id,
    tenant_id: tenant_id,
    order_no: "TV20260415001",
    product_type: "hotel",
    hotel_offer_id: hotel_offer_1.id,
    booking_mode: "standard",
    contact_name: "张三",
    contact_phone: "13800138001",
    traveler_count: 2,
    total_amount: Decimal.new("1196.00"),
    points_to_use: 0,
    points_deduction_amount: Decimal.new("0"),
    currency: "CNY",
    status: "draft",
    change_status: "none",
    waitlist_status: "none",
    supplier_order_ref: "CTRIP_HTL_20260415001",
    inserted_at: now,
    updated_at: now
  }
])
IO.puts("  订单: TV20260415001 酒店 (全季北京) ¥1196")

# 订单 2：机票订单 - 草稿
order_flight_id = Ash.UUID.generate()
UniboExPoc.Repo.insert_all("travel_orders", [
  %{
    id: order_flight_id,
    tenant_id: tenant_id,
    order_no: "TV20260420002",
    product_type: "flight",
    flight_offer_id: flight_offer_2.id,
    booking_mode: "standard",
    contact_name: "李四",
    contact_phone: "13900139002",
    traveler_count: 1,
    total_amount: Decimal.new("3560.00"),
    points_to_use: 500,
    points_deduction_amount: Decimal.new("50.00"),
    currency: "CNY",
    status: "draft",
    change_status: "none",
    waitlist_status: "none",
    supplier_order_ref: "CTRIP_FLT_20260420002",
    inserted_at: now,
    updated_at: now
  }
])
IO.puts("  订单: TV20260420002 机票 (MU5678) ¥3560")

# 订单 3：火车票订单 - 草稿
order_train_id = Ash.UUID.generate()
UniboExPoc.Repo.insert_all("travel_orders", [
  %{
    id: order_train_id,
    tenant_id: tenant_id,
    order_no: "TV20260415003",
    product_type: "train",
    train_offer_id: train_offer_1.id,
    booking_mode: "standard",
    contact_name: "王五",
    contact_phone: "13700137003",
    traveler_count: 1,
    total_amount: Decimal.new("553.00"),
    points_to_use: 0,
    points_deduction_amount: Decimal.new("0"),
    currency: "CNY",
    status: "draft",
    change_status: "none",
    waitlist_status: "none",
    ticket_passenger_infos: Jason.encode!(%{
      "passengers" => [
        %{"name" => "王五", "id_type" => "身份证", "id_no" => "110101199001011234"}
      ]
    }),
    seat_selection_snapshot: Jason.encode!(%{
      "preferred_seat" => "窗口",
      "coach" => "07",
      "seat" => "A"
    }),
    inserted_at: now,
    updated_at: now
  }
])
IO.puts("  订单: TV20260415003 火车票 (G1) ¥553")

# 订单 4：度假订单 - 草稿
order_vacation_id = Ash.UUID.generate()
UniboExPoc.Repo.insert_all("travel_orders", [
  %{
    id: order_vacation_id,
    tenant_id: tenant_id,
    order_no: "TV20260501004",
    product_type: "vacation",
    vacation_offer_id: vacation_offer_1.id,
    booking_mode: "standard",
    contact_name: "赵六",
    contact_phone: "13600136004",
    traveler_count: 2,
    total_amount: Decimal.new("9998.00"),
    points_to_use: 1000,
    points_deduction_amount: Decimal.new("100.00"),
    currency: "CNY",
    status: "draft",
    change_status: "none",
    waitlist_status: "none",
    inserted_at: now,
    updated_at: now
  }
])
IO.puts("  订单: TV20260501004 度假 (三亚5日游) ¥9998")

# ══════════════════════════════════════════════════════════════
# 第四部分：履约数据（TravelFulfillment）
# 注意：create_fulfillment action 需要 order_id argument + manage_relationship
# 这里同样用 Repo.insert_all 直接写入
# ══════════════════════════════════════════════════════════════

IO.puts("\n--- 创建履约记录 ---")

# 酒店订单的履约 - pending
UniboExPoc.Repo.insert_all("travel_fulfillments", [
  %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    travel_order_id: order_hotel_id,
    fulfillment_type: "reserve_room",
    status: "pending",
    supplier_booking_ref: "CTRIP_BOOK_HTL_001",
    waitlist_result: "none",
    change_result: "none",
    boarding_status: "not_started",
    inserted_at: now,
    updated_at: now
  }
])
IO.puts("  履约: 酒店预订确认 (pending)")

# 机票订单的履约 - pending
UniboExPoc.Repo.insert_all("travel_fulfillments", [
  %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    travel_order_id: order_flight_id,
    fulfillment_type: "issue_ticket",
    status: "pending",
    supplier_booking_ref: "CTRIP_BOOK_FLT_002",
    waitlist_result: "none",
    change_result: "none",
    boarding_status: "not_started",
    inserted_at: now,
    updated_at: now
  }
])
IO.puts("  履约: 机票出票 (pending)")

# 火车票订单的履约 - pending
UniboExPoc.Repo.insert_all("travel_fulfillments", [
  %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    travel_order_id: order_train_id,
    fulfillment_type: "issue_train_ticket",
    status: "pending",
    supplier_booking_ref: "12306_BOOK_TRN_003",
    waitlist_result: "none",
    change_result: "none",
    boarding_status: "not_started",
    inserted_at: now,
    updated_at: now
  }
])
IO.puts("  履约: 火车票出票 (pending)")

IO.puts("\n========================================")
IO.puts("  Travel 域 Seed 数据创建完成!")
IO.puts("========================================\n")
