[PAGE: vacation_offer_list]
  ATTR: Title("VacationOffer 列表")

  [SECTION: vacation_offer_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: vacation_offer_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|VacationOffer 列表}}"
    [BUTTON: vacation_offer_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: vacation_offer_filter_card]
    [CARD_CONTENT: vacation_offer_filter_content]
      [FLEX: vacation_offer_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_package_type]
          ATTR: Name("package_type"), Label("套餐类型")
        [INPUT: filter_start_date_from]
          ATTR: Name("start_date_from"), Label("出行开始日期 起")
        [INPUT: filter_start_date_to]
          ATTR: Name("start_date_to"), Label("出行开始日期 止")
        [INPUT: filter_end_date_from]
          ATTR: Name("end_date_from"), Label("出行结束日期 起")
        [INPUT: filter_end_date_to]
          ATTR: Name("end_date_to"), Label("出行结束日期 止")
        [SELECT: filter_sale_status]
          ATTR: Name("sale_status"), Label("sale_status")
        [BUTTON: vacation_offer_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: vacation_offer_table]
    [TABLE_HEADER: vacation_offer_table_header]
      [TABLE_ROW: vacation_offer_header_row]
        [TABLE_HEAD: th_tenant_id]
          CONTENT: "tenant_id"
        [TABLE_HEAD: th_host_shop_id]
          CONTENT: "宿主商城 ID，仅用于宿主侧隔离和桥接上下文"
        [TABLE_HEAD: th_supplier_code]
          CONTENT: "供应商编码"
        [TABLE_HEAD: th_package_code]
          CONTENT: "套餐编码"
        [TABLE_HEAD: th_package_name]
          CONTENT: "套餐名称"
        [TABLE_HEAD: th_package_type]
          CONTENT: "套餐类型"
        [TABLE_HEAD: th_departure_city_code]
          CONTENT: "出发城市编码"
        [TABLE_HEAD: th_destination_code]
          CONTENT: "目的地编码"
        [TABLE_HEAD: th_start_date]
          CONTENT: "出行开始日期"
        [TABLE_HEAD: th_end_date]
          CONTENT: "出行结束日期"
        [TABLE_HEAD: th_listed_price]
          CONTENT: "对客展示价快照"
        [TABLE_HEAD: th_settlement_price]
          CONTENT: "结算价快照"
        [TABLE_HEAD: th_currency]
          CONTENT: "currency"
        [TABLE_HEAD: th_inventory_count]
          CONTENT: "可售库存快照"
        [TABLE_HEAD: th_booking_rules]
          CONTENT: "预订规则快照"
        [TABLE_HEAD: th_cancellation_policy]
          CONTENT: "取消规则快照"
        [TABLE_HEAD: th_sale_status]
          CONTENT: "sale_status"
    [TABLE_BODY: vacation_offer_table_body]
      [FOR: row in rows]
        [TABLE_ROW: vacation_offer_row]
          [TABLE_CELL: td_tenant_id]
            CONTENT: "{{row.tenant_id|}}"
          [TABLE_CELL: td_host_shop_id]
            CONTENT: "{{row.host_shop_id|}}"
          [TABLE_CELL: td_supplier_code]
            CONTENT: "{{row.supplier_code|}}"
          [TABLE_CELL: td_package_code]
            CONTENT: "{{row.package_code|}}"
          [TABLE_CELL: td_package_name]
            CONTENT: "{{row.package_name|}}"
          [TABLE_CELL: td_package_type]
            [BADGE: badge_package_type]
              CONTENT: "{{row.package_type|}}"
          [TABLE_CELL: td_departure_city_code]
            CONTENT: "{{row.departure_city_code|}}"
          [TABLE_CELL: td_destination_code]
            CONTENT: "{{row.destination_code|}}"
          [TABLE_CELL: td_start_date]
            CONTENT: "{{row.start_date|}}"
          [TABLE_CELL: td_end_date]
            CONTENT: "{{row.end_date|}}"
          [TABLE_CELL: td_listed_price]
            CONTENT: "{{row.listed_price|}}"
          [TABLE_CELL: td_settlement_price]
            CONTENT: "{{row.settlement_price|}}"
          [TABLE_CELL: td_currency]
            CONTENT: "{{row.currency|}}"
          [TABLE_CELL: td_inventory_count]
            CONTENT: "{{row.inventory_count|}}"
          [TABLE_CELL: td_booking_rules]
            CONTENT: "{{row.booking_rules|}}"
          [TABLE_CELL: td_cancellation_policy]
            CONTENT: "{{row.cancellation_policy|}}"
          [TABLE_CELL: td_sale_status]
            [BADGE: badge_sale_status]
              CONTENT: "{{row.sale_status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: vacation_offer_no_data]
      ATTR: Description("暂无度假可售 offer，承载套餐、出发日期和预订规则快照数据")
  [/IF]
