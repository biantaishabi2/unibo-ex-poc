# Travel 域种子数据
#
# 运行方式：mix run priv/repo/seeds.exs
#
# 创建最小验证数据集：
# - 3 个航司（国航CA、东航MU、南航CZ）
# - 3 个舱位等级（经济舱、公务舱、头等舱）
# - 3 个酒店（北京国贸、上海华尔道夫、广州白天鹅）

alias UniboExPoc.Travel.{TravelAirline, TravelCabinClass, TravelHotel}
require Logger

Logger.info("✈️  开始创建 Travel 种子数据...")

# ── 1. 航司 ──────────────────────────────────────────────

airline_data = [
  %{airline_code: "AIR_CA", airline_name: "中国国际航空", iata_code: "CA", icao_code: "CCA", status: :active},
  %{airline_code: "AIR_MU", airline_name: "中国东方航空", iata_code: "MU", icao_code: "CES", status: :active},
  %{airline_code: "AIR_CZ", airline_name: "中国南方航空", iata_code: "CZ", icao_code: "CSN", status: :active}
]

airlines = Enum.map(airline_data, fn attrs ->
  {:ok, airline} = Ash.create(TravelAirline, attrs, authorize?: false)
  Logger.info("  航司: #{airline.airline_name} (#{airline.iata_code}/#{airline.icao_code})")
  airline
end)

# ── 2. 舱位等级 ──────────────────────────────────────────

cabin_class_data = [
  %{cabin_class_code: "CC_F", cabin_class_name: "头等舱", cabin_rank: 1, status: :active},
  %{cabin_class_code: "CC_C", cabin_class_name: "公务舱", cabin_rank: 2, status: :active},
  %{cabin_class_code: "CC_Y", cabin_class_name: "经济舱", cabin_rank: 3, status: :active}
]

cabin_classes = Enum.map(cabin_class_data, fn attrs ->
  {:ok, cc} = Ash.create(TravelCabinClass, attrs, authorize?: false)
  Logger.info("  舱位: #{cc.cabin_class_name} (#{cc.cabin_class_code}, rank=#{cc.cabin_rank})")
  cc
end)

# ── 3. 酒店 ──────────────────────────────────────────────

hotel_data = [
  %{hotel_code: "HTL_BJ_001", hotel_name: "北京国贸大酒店", city_code: "BJS", hotel_star: "五星级", status: :active},
  %{hotel_code: "HTL_SH_002", hotel_name: "上海外滩华尔道夫酒店", city_code: "SHA", hotel_star: "五星级", status: :active},
  %{hotel_code: "HTL_GZ_003", hotel_name: "广州白天鹅宾馆", city_code: "CAN", hotel_star: "五星级", status: :active}
]

hotels = Enum.map(hotel_data, fn attrs ->
  {:ok, hotel} = Ash.create(TravelHotel, attrs, authorize?: false)
  Logger.info("  酒店: #{hotel.hotel_name} (#{hotel.hotel_code}, #{hotel.city_code})")
  hotel
end)

Logger.info("""

✅ Travel 种子数据创建完成！

  航司: #{length(airlines)} 个（国航CA、东航MU、南航CZ）
  舱位: #{length(cabin_classes)} 个（头等舱、公务舱、经济舱）
  酒店: #{length(hotels)} 个（北京、上海、广州）
""")
