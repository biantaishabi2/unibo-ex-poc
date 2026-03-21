[PAGE: flight_offer_list]
  META: Entity("FlightOffer"), Domain("Travel")
  ATTR: Title("FlightOffer 列表")

  [SECTION: flight_offer_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: flight_offer_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|FlightOffer 列表}}"
    [BUTTON: flight_offer_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: flight_offer_filter_card]
    [CARD_CONTENT: flight_offer_filter_content]
      [FLEX: flight_offer_filter_row]
        { Gap: 4, Align: "Center" }
        [INPUT: filter_departure_at_from]
          ATTR: Name("departure_at_from"), Label("起飞时间 起")
        [INPUT: filter_departure_at_to]
          ATTR: Name("departure_at_to"), Label("起飞时间 止")
        [INPUT: filter_arrival_at_from]
          ATTR: Name("arrival_at_from"), Label("到达时间 起")
        [INPUT: filter_arrival_at_to]
          ATTR: Name("arrival_at_to"), Label("到达时间 止")
        [SELECT: filter_sale_status]
          ATTR: Name("sale_status"), Label("sale_status")
          BIND: Enum("FlightOffer", "sale_status")
        [BUTTON: flight_offer_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: flight_offer_table]
    [TABLE_HEADER: flight_offer_table_header]
      [TABLE_ROW: flight_offer_header_row]
        [TABLE_HEAD: th_tenant_id]
          CONTENT: "tenant_id"
        [TABLE_HEAD: th_host_shop_id]
          CONTENT: "宿主商城 ID，仅用于宿主侧隔离和桥接上下文"
        [TABLE_HEAD: th_supplier_code]
          CONTENT: "供应商编码"
        [TABLE_HEAD: th_itinerary_code]
          CONTENT: "行程编码"
        [TABLE_HEAD: th_flight_no]
          CONTENT: "航班号"
        [TABLE_HEAD: th_departure_airport_code]
          CONTENT: "出发机场编码"
        [TABLE_HEAD: th_arrival_airport_code]
          CONTENT: "到达机场编码"
        [TABLE_HEAD: th_departure_at]
          CONTENT: "起飞时间"
        [TABLE_HEAD: th_arrival_at]
          CONTENT: "到达时间"
        [TABLE_HEAD: th_cabin_class]
          CONTENT: "舱等"
        [TABLE_HEAD: th_fare_family]
          CONTENT: "运价族"
        [TABLE_HEAD: th_listed_price]
          CONTENT: "对客展示价快照"
        [TABLE_HEAD: th_settlement_price]
          CONTENT: "结算价快照"
        [TABLE_HEAD: th_currency]
          CONTENT: "currency"
        [TABLE_HEAD: th_seats_available]
          CONTENT: "可售座位快照"
        [TABLE_HEAD: th_baggage_policy]
          CONTENT: "行李规则快照"
        [TABLE_HEAD: th_refund_change_policy]
          CONTENT: "退改规则快照"
        [TABLE_HEAD: th_sale_status]
          CONTENT: "sale_status"
    [TABLE_BODY: flight_offer_table_body]
      [FOR: row in rows]
        [TABLE_ROW: flight_offer_row]
          [TABLE_CELL: td_tenant_id]
            CONTENT: "{{row.tenant_id|}}"
          [TABLE_CELL: td_host_shop_id]
            CONTENT: "{{row.host_shop_id|}}"
          [TABLE_CELL: td_supplier_code]
            CONTENT: "{{row.supplier_code|}}"
          [TABLE_CELL: td_itinerary_code]
            CONTENT: "{{row.itinerary_code|}}"
          [TABLE_CELL: td_flight_no]
            CONTENT: "{{row.flight_no|}}"
          [TABLE_CELL: td_departure_airport_code]
            CONTENT: "{{row.departure_airport_code|}}"
          [TABLE_CELL: td_arrival_airport_code]
            CONTENT: "{{row.arrival_airport_code|}}"
          [TABLE_CELL: td_departure_at]
            CONTENT: "{{row.departure_at|}}"
          [TABLE_CELL: td_arrival_at]
            CONTENT: "{{row.arrival_at|}}"
          [TABLE_CELL: td_cabin_class]
            CONTENT: "{{row.cabin_class|}}"
          [TABLE_CELL: td_fare_family]
            CONTENT: "{{row.fare_family|}}"
          [TABLE_CELL: td_listed_price]
            CONTENT: "{{row.listed_price|}}"
          [TABLE_CELL: td_settlement_price]
            CONTENT: "{{row.settlement_price|}}"
          [TABLE_CELL: td_currency]
            CONTENT: "{{row.currency|}}"
          [TABLE_CELL: td_seats_available]
            CONTENT: "{{row.seats_available|}}"
          [TABLE_CELL: td_baggage_policy]
            CONTENT: "{{row.baggage_policy|}}"
          [TABLE_CELL: td_refund_change_policy]
            CONTENT: "{{row.refund_change_policy|}}"
          [TABLE_CELL: td_sale_status]
            [BADGE: badge_sale_status]
              CONTENT: "{{row.sale_status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: flight_offer_no_data]
      ATTR: Description("暂无机票可售 offer，承载航班、舱位、票规和库存快照数据")
  [/IF]
