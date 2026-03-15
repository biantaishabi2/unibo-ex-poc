[PAGE: train_offer_list]
  ATTR: Title("TrainOffer 列表")

  [SECTION: train_offer_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: train_offer_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TrainOffer 列表}}"
    [BUTTON: train_offer_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: train_offer_filter_card]
    [CARD_CONTENT: train_offer_filter_content]
      [FLEX: train_offer_filter_row]
        { Gap: 4, Align: "Center" }
        [INPUT: filter_travel_date_from]
          ATTR: Name("travel_date_from"), Label("乘车日期 起")
        [INPUT: filter_travel_date_to]
          ATTR: Name("travel_date_to"), Label("乘车日期 止")
        [INPUT: filter_departure_at_from]
          ATTR: Name("departure_at_from"), Label("发车时间 起")
        [INPUT: filter_departure_at_to]
          ATTR: Name("departure_at_to"), Label("发车时间 止")
        [INPUT: filter_arrival_at_from]
          ATTR: Name("arrival_at_from"), Label("到达时间 起")
        [INPUT: filter_arrival_at_to]
          ATTR: Name("arrival_at_to"), Label("到达时间 止")
        [SELECT: filter_inventory_status]
          ATTR: Name("inventory_status"), Label("余票或候补可用状态")
        [SELECT: filter_sale_status]
          ATTR: Name("sale_status"), Label("可售状态")
        [BUTTON: train_offer_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: train_offer_table]
    [TABLE_HEADER: train_offer_table_header]
      [TABLE_ROW: train_offer_header_row]
        [TABLE_HEAD: th_tenant_id]
          CONTENT: "tenant_id"
        [TABLE_HEAD: th_host_shop_id]
          CONTENT: "宿主商城 ID，仅用于宿主侧隔离和桥接上下文"
        [TABLE_HEAD: th_supplier_code]
          CONTENT: "供应商编码"
        [TABLE_HEAD: th_train_no]
          CONTENT: "车次号"
        [TABLE_HEAD: th_departure_station_code]
          CONTENT: "出发站编码"
        [TABLE_HEAD: th_departure_station_name]
          CONTENT: "出发站名称"
        [TABLE_HEAD: th_arrival_station_code]
          CONTENT: "到达站编码"
        [TABLE_HEAD: th_arrival_station_name]
          CONTENT: "到达站名称"
        [TABLE_HEAD: th_travel_date]
          CONTENT: "乘车日期"
        [TABLE_HEAD: th_departure_at]
          CONTENT: "发车时间"
        [TABLE_HEAD: th_arrival_at]
          CONTENT: "到达时间"
        [TABLE_HEAD: th_seat_class]
          CONTENT: "席别名称"
        [TABLE_HEAD: th_seat_code]
          CONTENT: "席别编码"
        [TABLE_HEAD: th_is_no_seat]
          CONTENT: "是否无座票"
        [TABLE_HEAD: th_inventory_status]
          CONTENT: "余票或候补可用状态"
        [TABLE_HEAD: th_waitlist_supported]
          CONTENT: "是否支持候补"
        [TABLE_HEAD: th_listed_price]
          CONTENT: "对客展示价快照"
        [TABLE_HEAD: th_settlement_price]
          CONTENT: "结算价快照"
        [TABLE_HEAD: th_currency]
          CONTENT: "currency"
        [TABLE_HEAD: th_booking_rules_snapshot]
          CONTENT: "预订规则快照"
        [TABLE_HEAD: th_change_rules_snapshot]
          CONTENT: "改签规则快照"
        [TABLE_HEAD: th_refund_rules_snapshot]
          CONTENT: "退票规则快照"
        [TABLE_HEAD: th_sale_status]
          CONTENT: "可售状态"
    [TABLE_BODY: train_offer_table_body]
      [FOR: row in rows]
        [TABLE_ROW: train_offer_row]
          [TABLE_CELL: td_tenant_id]
            CONTENT: "{{row.tenant_id|}}"
          [TABLE_CELL: td_host_shop_id]
            CONTENT: "{{row.host_shop_id|}}"
          [TABLE_CELL: td_supplier_code]
            CONTENT: "{{row.supplier_code|}}"
          [TABLE_CELL: td_train_no]
            CONTENT: "{{row.train_no|}}"
          [TABLE_CELL: td_departure_station_code]
            CONTENT: "{{row.departure_station_code|}}"
          [TABLE_CELL: td_departure_station_name]
            CONTENT: "{{row.departure_station_name|}}"
          [TABLE_CELL: td_arrival_station_code]
            CONTENT: "{{row.arrival_station_code|}}"
          [TABLE_CELL: td_arrival_station_name]
            CONTENT: "{{row.arrival_station_name|}}"
          [TABLE_CELL: td_travel_date]
            CONTENT: "{{row.travel_date|}}"
          [TABLE_CELL: td_departure_at]
            CONTENT: "{{row.departure_at|}}"
          [TABLE_CELL: td_arrival_at]
            CONTENT: "{{row.arrival_at|}}"
          [TABLE_CELL: td_seat_class]
            CONTENT: "{{row.seat_class|}}"
          [TABLE_CELL: td_seat_code]
            CONTENT: "{{row.seat_code|}}"
          [TABLE_CELL: td_is_no_seat]
            [BADGE: badge_is_no_seat]
              CONTENT: "{{row.is_no_seat|}}"
          [TABLE_CELL: td_inventory_status]
            [BADGE: badge_inventory_status]
              CONTENT: "{{row.inventory_status|}}"
          [TABLE_CELL: td_waitlist_supported]
            [BADGE: badge_waitlist_supported]
              CONTENT: "{{row.waitlist_supported|}}"
          [TABLE_CELL: td_listed_price]
            CONTENT: "{{row.listed_price|}}"
          [TABLE_CELL: td_settlement_price]
            CONTENT: "{{row.settlement_price|}}"
          [TABLE_CELL: td_currency]
            CONTENT: "{{row.currency|}}"
          [TABLE_CELL: td_booking_rules_snapshot]
            CONTENT: "{{row.booking_rules_snapshot|}}"
          [TABLE_CELL: td_change_rules_snapshot]
            CONTENT: "{{row.change_rules_snapshot|}}"
          [TABLE_CELL: td_refund_rules_snapshot]
            CONTENT: "{{row.refund_rules_snapshot|}}"
          [TABLE_CELL: td_sale_status]
            [BADGE: badge_sale_status]
              CONTENT: "{{row.sale_status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: train_offer_no_data]
      ATTR: Description("暂无火车票可售 offer，承载车次、席别、候补和退改规则快照数据")
  [/IF]
