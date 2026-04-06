# 自动生成的 seed data，可用 AI 修改值使其有业务含义
# 生成命令: unibo generate-seeds

# 幂等清理（拓扑逆序，先删子实体再删父实体）
alias UniboExPoc.Repo

safe_delete_all = fn module ->
  try do
    Repo.delete_all(module)
  rescue
    _ -> :ok
  end
end

# 先删 AshPaperTrail 版本表
safe_delete_all.(UniboExPoc.Travel.TravelRefundOrder.Version)
safe_delete_all.(UniboExPoc.Travel.TravelPolicyCheck.Version)
safe_delete_all.(UniboExPoc.Travel.TravelFulfillment.Version)
safe_delete_all.(UniboExPoc.Travel.TravelChangeOrder.Version)
safe_delete_all.(UniboExPoc.Travel.TravelOrder.Version)
safe_delete_all.(UniboExPoc.Travel.HotelOffer.Version)
safe_delete_all.(UniboExPoc.Travel.TravelRoomType.Version)
safe_delete_all.(UniboExPoc.Travel.FlightOffer.Version)
safe_delete_all.(UniboExPoc.Travel.VacationOffer.Version)
safe_delete_all.(UniboExPoc.Travel.TravelStaticCodeMapping.Version)
safe_delete_all.(UniboExPoc.Travel.TravelPolicy.Version)
safe_delete_all.(UniboExPoc.Travel.TravelHotel.Version)
safe_delete_all.(UniboExPoc.Travel.TravelCabinClass.Version)
safe_delete_all.(UniboExPoc.Travel.TravelAirline.Version)
safe_delete_all.(UniboExPoc.Travel.TrainOffer.Version)

safe_delete_all.(UniboExPoc.Travel.TravelRefundOrder)
safe_delete_all.(UniboExPoc.Travel.TravelPolicyCheck)
safe_delete_all.(UniboExPoc.Travel.TravelFulfillment)
safe_delete_all.(UniboExPoc.Travel.TravelChangeOrder)
safe_delete_all.(UniboExPoc.Travel.TravelOrder)
safe_delete_all.(UniboExPoc.Travel.HotelOffer)
safe_delete_all.(UniboExPoc.Travel.TravelRoomType)
safe_delete_all.(UniboExPoc.Travel.FlightOffer)
safe_delete_all.(UniboExPoc.Travel.VacationOffer)
safe_delete_all.(UniboExPoc.Travel.TravelStaticCodeMapping)
safe_delete_all.(UniboExPoc.Travel.TravelPolicy)
safe_delete_all.(UniboExPoc.Travel.TravelHotel)
safe_delete_all.(UniboExPoc.Travel.TravelCabinClass)
safe_delete_all.(UniboExPoc.Travel.TravelAirline)
safe_delete_all.(UniboExPoc.Travel.TrainOffer)

# 多租户 tenant ID（直接赋值到 struct 字段）
tenant_id = "00000000-0000-0000-0000-000000000001"

# 容错包装：跳过不存在的表或约束冲突
is_ash_string_type = fn type ->
  case type do
    :string -> true
    {:parameterized, {Ash.Type.String.EctoType, _}} -> true
    _ -> false
  end
end

coerce_struct = fn struct_val ->
  schema = struct_val.__struct__
  if function_exported?(schema, :__schema__, 1) do
    fields = schema.__schema__(:fields)
    Enum.reduce(fields, struct_val, fn field, acc ->
      val = Map.get(acc, field)
      field_type = schema.__schema__(:type, field)
      if is_ash_string_type.(field_type) do
        case val do
          %DateTime{} -> Map.put(acc, field, DateTime.to_iso8601(val))
          %NaiveDateTime{} -> Map.put(acc, field, NaiveDateTime.to_iso8601(val))
          %Date{} -> Map.put(acc, field, Date.to_iso8601(val))
          _ -> acc
        end
      else
        acc
      end
    end)
  else
    struct_val
  end
end

safe_insert = fn module, attrs ->
  if not Code.ensure_loaded?(module) do
    IO.puts("SKIP: #{inspect(module)} 未编译，请先跑 compile-project")
    %{id: attrs[:id] || Ash.UUID.generate()}
  else
    try do
      coerced = coerce_struct.(struct!(module, attrs))
      UniboExPoc.Repo.insert!(coerced)
    rescue
      e ->
        IO.puts("WARN: #{inspect(module)}: #{Exception.message(e)}")
        %{id: attrs[:id] || Ash.UUID.generate()}
    end
  end
end

travel_train_offer_001 =
  safe_insert.(UniboExPoc.Travel.TrainOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_001",
    train_no: "train_no_001",
    departure_station_code: "departure_station_code_001",
    departure_station_name: "departure_station_name_001",
    arrival_station_code: "arrival_station_code_001",
    arrival_station_name: "arrival_station_name_001",
    travel_date: ~D[2026-01-01],
    departure_at: ~U[2026-01-01T00:00:00Z],
    arrival_at: ~U[2026-01-01T00:00:00Z],
    seat_class: "seat_class_001",
    seat_code: "seat_code_001",
    is_no_seat: true,
    inventory_status: :"available",
    waitlist_supported: true,
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_001",
    booking_rules_snapshot: "Lorem ipsum booking_rules_snapshot",
    change_rules_snapshot: "Lorem ipsum change_rules_snapshot",
    refund_rules_snapshot: "Lorem ipsum refund_rules_snapshot",
    sale_status: :"draft",
    arrival_station_ref_id: nil,
    departure_station_ref_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_train_offer_002 =
  safe_insert.(UniboExPoc.Travel.TrainOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_002",
    train_no: "train_no_002",
    departure_station_code: "departure_station_code_002",
    departure_station_name: "departure_station_name_002",
    arrival_station_code: "arrival_station_code_002",
    arrival_station_name: "arrival_station_name_002",
    travel_date: ~D[2026-01-01],
    departure_at: ~U[2026-01-01T00:00:00Z],
    arrival_at: ~U[2026-01-01T00:00:00Z],
    seat_class: "seat_class_002",
    seat_code: "seat_code_002",
    is_no_seat: true,
    inventory_status: :"waitlist_only",
    waitlist_supported: true,
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_002",
    booking_rules_snapshot: "Lorem ipsum booking_rules_snapshot",
    change_rules_snapshot: "Lorem ipsum change_rules_snapshot",
    refund_rules_snapshot: "Lorem ipsum refund_rules_snapshot",
    sale_status: :"draft",
    departure_station_ref_id: nil,
    arrival_station_ref_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_train_offer_003 =
  safe_insert.(UniboExPoc.Travel.TrainOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_003",
    train_no: "train_no_003",
    departure_station_code: "departure_station_code_003",
    departure_station_name: "departure_station_name_003",
    arrival_station_code: "arrival_station_code_003",
    arrival_station_name: "arrival_station_name_003",
    travel_date: ~D[2026-01-01],
    departure_at: ~U[2026-01-01T00:00:00Z],
    arrival_at: ~U[2026-01-01T00:00:00Z],
    seat_class: "seat_class_003",
    seat_code: "seat_code_003",
    is_no_seat: true,
    inventory_status: :"sold_out",
    waitlist_supported: true,
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_003",
    booking_rules_snapshot: "Lorem ipsum booking_rules_snapshot",
    change_rules_snapshot: "Lorem ipsum change_rules_snapshot",
    refund_rules_snapshot: "Lorem ipsum refund_rules_snapshot",
    sale_status: :"draft",
    arrival_station_ref_id: nil,
    departure_station_ref_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_airline_001 =
  safe_insert.(UniboExPoc.Travel.TravelAirline, %{
    id: Ash.UUID.generate(),
    airline_code: "airline_code_001",
    airline_name: "airline_name_001",
    iata_code: "iata_code_001",
    icao_code: "icao_code_001",
    status: :"active",
  })

travel_travel_airline_002 =
  safe_insert.(UniboExPoc.Travel.TravelAirline, %{
    id: Ash.UUID.generate(),
    airline_code: "airline_code_002",
    airline_name: "airline_name_002",
    iata_code: "iata_code_002",
    icao_code: "icao_code_002",
    status: :"inactive",
  })

travel_travel_airline_003 =
  safe_insert.(UniboExPoc.Travel.TravelAirline, %{
    id: Ash.UUID.generate(),
    airline_code: "airline_code_003",
    airline_name: "airline_name_003",
    iata_code: "iata_code_003",
    icao_code: "icao_code_003",
    status: :"active",
  })

travel_travel_cabin_class_001 =
  safe_insert.(UniboExPoc.Travel.TravelCabinClass, %{
    id: Ash.UUID.generate(),
    cabin_class_code: "cabin_class_code_001",
    cabin_class_name: "cabin_class_name_001",
    cabin_rank: 1,
    status: :"active",
  })

travel_travel_cabin_class_002 =
  safe_insert.(UniboExPoc.Travel.TravelCabinClass, %{
    id: Ash.UUID.generate(),
    cabin_class_code: "cabin_class_code_002",
    cabin_class_name: "cabin_class_name_002",
    cabin_rank: 2,
    status: :"inactive",
  })

travel_travel_cabin_class_003 =
  safe_insert.(UniboExPoc.Travel.TravelCabinClass, %{
    id: Ash.UUID.generate(),
    cabin_class_code: "cabin_class_code_003",
    cabin_class_name: "cabin_class_name_003",
    cabin_rank: 3,
    status: :"active",
  })

travel_travel_hotel_001 =
  safe_insert.(UniboExPoc.Travel.TravelHotel, %{
    id: Ash.UUID.generate(),
    hotel_code: "hotel_code_001",
    hotel_name: "hotel_name_001",
    city_code: "city_code_001",
    hotel_star: "hotel_star_001",
    status: :"active",
    city_id: nil,
  })

travel_travel_hotel_002 =
  safe_insert.(UniboExPoc.Travel.TravelHotel, %{
    id: Ash.UUID.generate(),
    hotel_code: "hotel_code_002",
    hotel_name: "hotel_name_002",
    city_code: "city_code_002",
    hotel_star: "hotel_star_002",
    status: :"inactive",
    city_id: nil,
  })

travel_travel_hotel_003 =
  safe_insert.(UniboExPoc.Travel.TravelHotel, %{
    id: Ash.UUID.generate(),
    hotel_code: "hotel_code_003",
    hotel_name: "hotel_name_003",
    city_code: "city_code_003",
    hotel_star: "hotel_star_003",
    status: :"active",
    city_id: nil,
  })

travel_travel_policy_001 =
  safe_insert.(UniboExPoc.Travel.TravelPolicy, %{
    id: Ash.UUID.generate(),
    policy_name: "policy_name_001",
    product_type: :"flight",
    employee_level: "employee_level_001",
    city_tier: "city_tier_001",
    season: "season_001",
    max_amount: 1,
    cabin_class_limit: "cabin_class_limit_001",
    hotel_star_limit: "hotel_star_limit_001",
    exceed_strategy: :"block",
    approval_mode: :"none",
    personal_pay_ratio: 1,
    is_active: true,
    enterprise_id: "enterprise_id_001",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_policy_002 =
  safe_insert.(UniboExPoc.Travel.TravelPolicy, %{
    id: Ash.UUID.generate(),
    policy_name: "policy_name_002",
    product_type: :"hotel",
    employee_level: "employee_level_002",
    city_tier: "city_tier_002",
    season: "season_002",
    max_amount: 2,
    cabin_class_limit: "cabin_class_limit_002",
    hotel_star_limit: "hotel_star_limit_002",
    exceed_strategy: :"require_reason",
    approval_mode: :"self",
    personal_pay_ratio: 2,
    is_active: true,
    enterprise_id: "enterprise_id_002",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_policy_003 =
  safe_insert.(UniboExPoc.Travel.TravelPolicy, %{
    id: Ash.UUID.generate(),
    policy_name: "policy_name_003",
    product_type: :"train",
    employee_level: "employee_level_003",
    city_tier: "city_tier_003",
    season: "season_003",
    max_amount: 3,
    cabin_class_limit: "cabin_class_limit_003",
    hotel_star_limit: "hotel_star_limit_003",
    exceed_strategy: :"require_approval",
    approval_mode: :"oa",
    personal_pay_ratio: 3,
    is_active: true,
    enterprise_id: "enterprise_id_003",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_static_code_mapping_001 =
  safe_insert.(UniboExPoc.Travel.TravelStaticCodeMapping, %{
    id: Ash.UUID.generate(),
    supplier_code: "supplier_code_001",
    object_type: :"city",
    canonical_entity: "canonical_entity_001",
    canonical_id: Ash.UUID.generate(),
    external_code: "external_code_001",
    external_name: "external_name_001",
    status: :"active",
  })

travel_travel_static_code_mapping_002 =
  safe_insert.(UniboExPoc.Travel.TravelStaticCodeMapping, %{
    id: Ash.UUID.generate(),
    supplier_code: "supplier_code_002",
    object_type: :"airport",
    canonical_entity: "canonical_entity_002",
    canonical_id: Ash.UUID.generate(),
    external_code: "external_code_002",
    external_name: "external_name_002",
    status: :"inactive",
  })

travel_travel_static_code_mapping_003 =
  safe_insert.(UniboExPoc.Travel.TravelStaticCodeMapping, %{
    id: Ash.UUID.generate(),
    supplier_code: "supplier_code_003",
    object_type: :"station",
    canonical_entity: "canonical_entity_003",
    canonical_id: Ash.UUID.generate(),
    external_code: "external_code_003",
    external_name: "external_name_003",
    status: :"active",
  })

travel_vacation_offer_001 =
  safe_insert.(UniboExPoc.Travel.VacationOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_001",
    package_code: "package_code_001",
    package_name: "package_name_001",
    package_type: :"group_tour",
    departure_city_code: "departure_city_code_001",
    destination_code: "destination_code_001",
    start_date: ~D[2026-01-01],
    end_date: ~D[2026-01-01],
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_001",
    inventory_count: 1,
    booking_rules: "Lorem ipsum booking_rules",
    cancellation_policy: "Lorem ipsum cancellation_policy",
    sale_status: :"draft",
    destination_ref_id: nil,
    departure_city_ref_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_vacation_offer_002 =
  safe_insert.(UniboExPoc.Travel.VacationOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_002",
    package_code: "package_code_002",
    package_name: "package_name_002",
    package_type: :"free_travel",
    departure_city_code: "departure_city_code_002",
    destination_code: "destination_code_002",
    start_date: ~D[2026-01-01],
    end_date: ~D[2026-01-01],
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_002",
    inventory_count: 2,
    booking_rules: "Lorem ipsum booking_rules",
    cancellation_policy: "Lorem ipsum cancellation_policy",
    sale_status: :"draft",
    departure_city_ref_id: nil,
    destination_ref_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_vacation_offer_003 =
  safe_insert.(UniboExPoc.Travel.VacationOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_003",
    package_code: "package_code_003",
    package_name: "package_name_003",
    package_type: :"ticket_hotel",
    departure_city_code: "departure_city_code_003",
    destination_code: "destination_code_003",
    start_date: ~D[2026-01-01],
    end_date: ~D[2026-01-01],
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_003",
    inventory_count: 3,
    booking_rules: "Lorem ipsum booking_rules",
    cancellation_policy: "Lorem ipsum cancellation_policy",
    sale_status: :"draft",
    destination_ref_id: nil,
    departure_city_ref_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_flight_offer_001 =
  safe_insert.(UniboExPoc.Travel.FlightOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_001",
    itinerary_code: "itinerary_code_001",
    flight_no: "flight_no_001",
    departure_airport_code: "departure_airport_code_001",
    arrival_airport_code: "arrival_airport_code_001",
    departure_at: ~U[2026-01-01T00:00:00Z],
    arrival_at: ~U[2026-01-01T00:00:00Z],
    cabin_class: "cabin_class_001",
    fare_family: "fare_family_001",
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_001",
    seats_available: 1,
    baggage_policy: "Lorem ipsum baggage_policy",
    refund_change_policy: "Lorem ipsum refund_change_policy",
    sale_status: :"draft",
    airline_ref_id: travel_travel_airline_001.id,
    cabin_class_ref_id: travel_travel_cabin_class_001.id,
    departure_airport_ref_id: nil,
    arrival_airport_ref_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_flight_offer_002 =
  safe_insert.(UniboExPoc.Travel.FlightOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_002",
    itinerary_code: "itinerary_code_002",
    flight_no: "flight_no_002",
    departure_airport_code: "departure_airport_code_002",
    arrival_airport_code: "arrival_airport_code_002",
    departure_at: ~U[2026-01-01T00:00:00Z],
    arrival_at: ~U[2026-01-01T00:00:00Z],
    cabin_class: "cabin_class_002",
    fare_family: "fare_family_002",
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_002",
    seats_available: 2,
    baggage_policy: "Lorem ipsum baggage_policy",
    refund_change_policy: "Lorem ipsum refund_change_policy",
    sale_status: :"draft",
    arrival_airport_ref_id: nil,
    airline_ref_id: travel_travel_airline_002.id,
    cabin_class_ref_id: travel_travel_cabin_class_002.id,
    departure_airport_ref_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_flight_offer_003 =
  safe_insert.(UniboExPoc.Travel.FlightOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_003",
    itinerary_code: "itinerary_code_003",
    flight_no: "flight_no_003",
    departure_airport_code: "departure_airport_code_003",
    arrival_airport_code: "arrival_airport_code_003",
    departure_at: ~U[2026-01-01T00:00:00Z],
    arrival_at: ~U[2026-01-01T00:00:00Z],
    cabin_class: "cabin_class_003",
    fare_family: "fare_family_003",
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_003",
    seats_available: 3,
    baggage_policy: "Lorem ipsum baggage_policy",
    refund_change_policy: "Lorem ipsum refund_change_policy",
    sale_status: :"draft",
    airline_ref_id: travel_travel_airline_003.id,
    departure_airport_ref_id: nil,
    cabin_class_ref_id: travel_travel_cabin_class_003.id,
    arrival_airport_ref_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_room_type_001 =
  safe_insert.(UniboExPoc.Travel.TravelRoomType, %{
    id: Ash.UUID.generate(),
    room_type_code: "room_type_code_001",
    room_type_name: "room_type_name_001",
    hotel_code: "hotel_code_001",
    bed_type: "bed_type_001",
    status: :"active",
    hotel_id: travel_travel_hotel_001.id,
  })

travel_travel_room_type_002 =
  safe_insert.(UniboExPoc.Travel.TravelRoomType, %{
    id: Ash.UUID.generate(),
    room_type_code: "room_type_code_002",
    room_type_name: "room_type_name_002",
    hotel_code: "hotel_code_002",
    bed_type: "bed_type_002",
    status: :"inactive",
    hotel_id: travel_travel_hotel_002.id,
  })

travel_travel_room_type_003 =
  safe_insert.(UniboExPoc.Travel.TravelRoomType, %{
    id: Ash.UUID.generate(),
    room_type_code: "room_type_code_003",
    room_type_name: "room_type_name_003",
    hotel_code: "hotel_code_003",
    bed_type: "bed_type_003",
    status: :"active",
    hotel_id: travel_travel_hotel_003.id,
  })

travel_hotel_offer_001 =
  safe_insert.(UniboExPoc.Travel.HotelOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_001",
    hotel_code: "hotel_code_001",
    hotel_name: "hotel_name_001",
    city_code: "city_code_001",
    room_type_code: "room_type_code_001",
    rate_plan_code: "rate_plan_code_001",
    checkin_date: ~D[2026-01-01],
    checkout_date: ~D[2026-01-01],
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_001",
    inventory_count: 1,
    cancellation_policy: "Lorem ipsum cancellation_policy",
    guarantee_policy: "Lorem ipsum guarantee_policy",
    sale_status: :"draft",
    city_ref_id: nil,
    hotel_ref_id: travel_travel_hotel_001.id,
    room_type_ref_id: travel_travel_room_type_001.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_hotel_offer_002 =
  safe_insert.(UniboExPoc.Travel.HotelOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_002",
    hotel_code: "hotel_code_002",
    hotel_name: "hotel_name_002",
    city_code: "city_code_002",
    room_type_code: "room_type_code_002",
    rate_plan_code: "rate_plan_code_002",
    checkin_date: ~D[2026-01-01],
    checkout_date: ~D[2026-01-01],
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_002",
    inventory_count: 2,
    cancellation_policy: "Lorem ipsum cancellation_policy",
    guarantee_policy: "Lorem ipsum guarantee_policy",
    sale_status: :"draft",
    city_ref_id: nil,
    hotel_ref_id: travel_travel_hotel_002.id,
    room_type_ref_id: travel_travel_room_type_002.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_hotel_offer_003 =
  safe_insert.(UniboExPoc.Travel.HotelOffer, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    supplier_code: "supplier_code_003",
    hotel_code: "hotel_code_003",
    hotel_name: "hotel_name_003",
    city_code: "city_code_003",
    room_type_code: "room_type_code_003",
    rate_plan_code: "rate_plan_code_003",
    checkin_date: ~D[2026-01-01],
    checkout_date: ~D[2026-01-01],
    listed_price: Decimal.new("100.00"),
    settlement_price: Decimal.new("100.00"),
    currency: "currency_003",
    inventory_count: 3,
    cancellation_policy: "Lorem ipsum cancellation_policy",
    guarantee_policy: "Lorem ipsum guarantee_policy",
    sale_status: :"draft",
    room_type_ref_id: travel_travel_room_type_003.id,
    city_ref_id: nil,
    hotel_ref_id: travel_travel_hotel_003.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_order_001 =
  safe_insert.(UniboExPoc.Travel.TravelOrder, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    host_member_id: "host_member_id_001",
    host_enterprise_id: "host_enterprise_id_001",
    order_no: "order_no_001",
    product_type: :"hotel",
    booking_mode: :"standard",
    contact_name: "contact_name_001",
    contact_phone: "contact_phone_001",
    traveler_count: 1,
    total_amount: Decimal.new("100.00"),
    points_to_use: 1,
    points_deduction_amount: Decimal.new("100.00"),
    recommended_payment_method: "recommended_payment_method_001",
    currency: "currency_001",
    status: :"draft",
    change_status: :"none",
    waitlist_status: :"none",
    original_order_ref: "original_order_ref_001",
    ticket_passenger_infos: %{},
    seat_selection_snapshot: %{},
    supplier_order_ref: "supplier_order_ref_001",
    payment_external_ref: "payment_external_ref_001",
    train_offer_id: travel_train_offer_001.id,
    flight_offer_id: travel_flight_offer_001.id,
    vacation_offer_id: travel_vacation_offer_001.id,
    customer_id: nil,
    hotel_offer_id: travel_hotel_offer_001.id,
    payment_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_order_002 =
  safe_insert.(UniboExPoc.Travel.TravelOrder, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    host_member_id: "host_member_id_002",
    host_enterprise_id: "host_enterprise_id_002",
    order_no: "order_no_002",
    product_type: :"flight",
    booking_mode: :"waitlist",
    contact_name: "contact_name_002",
    contact_phone: "contact_phone_002",
    traveler_count: 2,
    total_amount: Decimal.new("100.00"),
    points_to_use: 2,
    points_deduction_amount: Decimal.new("100.00"),
    recommended_payment_method: "recommended_payment_method_002",
    currency: "currency_002",
    status: :"draft",
    change_status: :"pending",
    waitlist_status: :"pending",
    original_order_ref: "original_order_ref_002",
    ticket_passenger_infos: %{},
    seat_selection_snapshot: %{},
    supplier_order_ref: "supplier_order_ref_002",
    payment_external_ref: "payment_external_ref_002",
    flight_offer_id: travel_flight_offer_002.id,
    payment_id: nil,
    train_offer_id: travel_train_offer_002.id,
    customer_id: nil,
    hotel_offer_id: travel_hotel_offer_002.id,
    vacation_offer_id: travel_vacation_offer_002.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_order_003 =
  safe_insert.(UniboExPoc.Travel.TravelOrder, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    host_shop_id: Ash.UUID.generate(),
    host_member_id: "host_member_id_003",
    host_enterprise_id: "host_enterprise_id_003",
    order_no: "order_no_003",
    product_type: :"vacation",
    booking_mode: :"standard",
    contact_name: "contact_name_003",
    contact_phone: "contact_phone_003",
    traveler_count: 3,
    total_amount: Decimal.new("100.00"),
    points_to_use: 3,
    points_deduction_amount: Decimal.new("100.00"),
    recommended_payment_method: "recommended_payment_method_003",
    currency: "currency_003",
    status: :"draft",
    change_status: :"changed",
    waitlist_status: :"fulfilled",
    original_order_ref: "original_order_ref_003",
    ticket_passenger_infos: %{},
    seat_selection_snapshot: %{},
    supplier_order_ref: "supplier_order_ref_003",
    payment_external_ref: "payment_external_ref_003",
    customer_id: nil,
    hotel_offer_id: travel_hotel_offer_003.id,
    flight_offer_id: travel_flight_offer_003.id,
    vacation_offer_id: travel_vacation_offer_003.id,
    payment_id: nil,
    train_offer_id: travel_train_offer_003.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_change_order_001 =
  safe_insert.(UniboExPoc.Travel.TravelChangeOrder, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    change_reason: "change_reason_001",
    price_difference: "price_difference_001",
    change_fee: "change_fee_001",
    new_offer_id: "new_offer_id_001",
    status: :"pending",
    approval_mode: :"none",
    original_order_id: travel_travel_order_001.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_change_order_002 =
  safe_insert.(UniboExPoc.Travel.TravelChangeOrder, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    change_reason: "change_reason_002",
    price_difference: "price_difference_002",
    change_fee: "change_fee_002",
    new_offer_id: "new_offer_id_002",
    status: :"pending",
    approval_mode: :"self",
    original_order_id: travel_travel_order_002.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_change_order_003 =
  safe_insert.(UniboExPoc.Travel.TravelChangeOrder, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    change_reason: "change_reason_003",
    price_difference: "price_difference_003",
    change_fee: "change_fee_003",
    new_offer_id: "new_offer_id_003",
    status: :"pending",
    approval_mode: :"oa",
    original_order_id: travel_travel_order_003.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_fulfillment_001 =
  safe_insert.(UniboExPoc.Travel.TravelFulfillment, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    fulfillment_type: :"reserve_room",
    status: :"pending",
    supplier_booking_ref: "supplier_booking_ref_001",
    voucher_or_ticket_ref: "voucher_or_ticket_ref_001",
    ticket_refs: %{},
    waitlist_result: :"none",
    change_result: :"none",
    boarding_status: :"not_started",
    confirmation_payload: "Lorem ipsum confirmation_payload",
    failure_reason: "Lorem ipsum failure_reason",
    used_at: ~U[2026-01-01T00:00:00Z],
    travel_order_id: travel_travel_order_001.id,
    shipment_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_fulfillment_002 =
  safe_insert.(UniboExPoc.Travel.TravelFulfillment, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    fulfillment_type: :"issue_ticket",
    status: :"confirmed",
    supplier_booking_ref: "supplier_booking_ref_002",
    voucher_or_ticket_ref: "voucher_or_ticket_ref_002",
    ticket_refs: %{},
    waitlist_result: :"pending",
    change_result: :"pending",
    boarding_status: :"boarded",
    confirmation_payload: "Lorem ipsum confirmation_payload",
    failure_reason: "Lorem ipsum failure_reason",
    used_at: ~U[2026-01-01T00:00:00Z],
    shipment_id: nil,
    travel_order_id: travel_travel_order_002.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_fulfillment_003 =
  safe_insert.(UniboExPoc.Travel.TravelFulfillment, %{
    id: Ash.UUID.generate(),
    tenant_id: tenant_id,
    fulfillment_type: :"issue_voucher",
    status: :"issued",
    supplier_booking_ref: "supplier_booking_ref_003",
    voucher_or_ticket_ref: "voucher_or_ticket_ref_003",
    ticket_refs: %{},
    waitlist_result: :"fulfilled",
    change_result: :"changed",
    boarding_status: :"completed",
    confirmation_payload: "Lorem ipsum confirmation_payload",
    failure_reason: "Lorem ipsum failure_reason",
    used_at: ~U[2026-01-01T00:00:00Z],
    travel_order_id: travel_travel_order_003.id,
    shipment_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_policy_check_001 =
  safe_insert.(UniboExPoc.Travel.TravelPolicyCheck, %{
    id: Ash.UUID.generate(),
    check_result: :"compliant",
    policy_amount: 1,
    actual_amount: 1,
    exceed_amount: 1,
    exceed_ratio: "exceed_ratio_001",
    exceed_strategy: "exceed_strategy_001",
    exceed_reason: "exceed_reason_001",
    personal_pay_amount: 1,
    approval_request_id: "approval_request_id_001",
    approval_mode: :"none",
    order_id: travel_travel_order_001.id,
    policy_id: travel_travel_policy_001.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_policy_check_002 =
  safe_insert.(UniboExPoc.Travel.TravelPolicyCheck, %{
    id: Ash.UUID.generate(),
    check_result: :"exceeded",
    policy_amount: 2,
    actual_amount: 2,
    exceed_amount: 2,
    exceed_ratio: "exceed_ratio_002",
    exceed_strategy: "exceed_strategy_002",
    exceed_reason: "exceed_reason_002",
    personal_pay_amount: 2,
    approval_request_id: "approval_request_id_002",
    approval_mode: :"self",
    order_id: travel_travel_order_002.id,
    policy_id: travel_travel_policy_002.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_policy_check_003 =
  safe_insert.(UniboExPoc.Travel.TravelPolicyCheck, %{
    id: Ash.UUID.generate(),
    check_result: :"blocked",
    policy_amount: 3,
    actual_amount: 3,
    exceed_amount: 3,
    exceed_ratio: "exceed_ratio_003",
    exceed_strategy: "exceed_strategy_003",
    exceed_reason: "exceed_reason_003",
    personal_pay_amount: 3,
    approval_request_id: "approval_request_id_003",
    approval_mode: :"oa",
    policy_id: travel_travel_policy_003.id,
    order_id: travel_travel_order_003.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_refund_order_001 =
  safe_insert.(UniboExPoc.Travel.TravelRefundOrder, %{
    id: Ash.UUID.generate(),
    refund_reason: "refund_reason_001",
    refund_fee: "refund_fee_001",
    refund_amount: "refund_amount_001",
    status: :"pending",
    approval_mode: :"none",
    original_order_id: travel_travel_order_001.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_refund_order_002 =
  safe_insert.(UniboExPoc.Travel.TravelRefundOrder, %{
    id: Ash.UUID.generate(),
    refund_reason: "refund_reason_002",
    refund_fee: "refund_fee_002",
    refund_amount: "refund_amount_002",
    status: :"pending",
    approval_mode: :"self",
    original_order_id: travel_travel_order_002.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

travel_travel_refund_order_003 =
  safe_insert.(UniboExPoc.Travel.TravelRefundOrder, %{
    id: Ash.UUID.generate(),
    refund_reason: "refund_reason_003",
    refund_fee: "refund_fee_003",
    refund_amount: "refund_amount_003",
    status: :"pending",
    approval_mode: :"oa",
    original_order_id: travel_travel_order_003.id,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  })

