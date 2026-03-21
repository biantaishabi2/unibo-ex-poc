[PAGE: hotel_offer_list]
  META: Entity("HotelOffer"), Domain("Travel")
  ATTR: Title("HotelOffer 列表")

  [SECTION: hotel_offer_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: hotel_offer_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|HotelOffer 列表}}"
    [BUTTON: hotel_offer_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: hotel_offer_filter_card]
    [CARD_CONTENT: hotel_offer_filter_content]
      [FLEX: hotel_offer_filter_row]
        { Gap: 4, Align: "Center" }
        [INPUT: filter_checkin_date_from]
          ATTR: Name("checkin_date_from"), Label("入住日期 起")
        [INPUT: filter_checkin_date_to]
          ATTR: Name("checkin_date_to"), Label("入住日期 止")
        [INPUT: filter_checkout_date_from]
          ATTR: Name("checkout_date_from"), Label("离店日期 起")
        [INPUT: filter_checkout_date_to]
          ATTR: Name("checkout_date_to"), Label("离店日期 止")
        [SELECT: filter_sale_status]
          ATTR: Name("sale_status"), Label("可售状态")
          BIND: Enum("HotelOffer", "sale_status")
        [BUTTON: hotel_offer_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: hotel_offer_table]
    [TABLE_HEADER: hotel_offer_table_header]
      [TABLE_ROW: hotel_offer_header_row]
        [TABLE_HEAD: th_tenant_id]
          CONTENT: "租户 ID"
        [TABLE_HEAD: th_host_shop_id]
          CONTENT: "宿主商城 ID，仅用于宿主侧隔离和桥接上下文"
        [TABLE_HEAD: th_supplier_code]
          CONTENT: "供应商编码"
        [TABLE_HEAD: th_hotel_code]
          CONTENT: "酒店编码"
        [TABLE_HEAD: th_hotel_name]
          CONTENT: "酒店名称"
        [TABLE_HEAD: th_city_code]
          CONTENT: "城市编码"
        [TABLE_HEAD: th_room_type_code]
          CONTENT: "房型编码"
        [TABLE_HEAD: th_rate_plan_code]
          CONTENT: "价计划编码"
        [TABLE_HEAD: th_checkin_date]
          CONTENT: "入住日期"
        [TABLE_HEAD: th_checkout_date]
          CONTENT: "离店日期"
        [TABLE_HEAD: th_listed_price]
          CONTENT: "对客展示价快照"
        [TABLE_HEAD: th_settlement_price]
          CONTENT: "结算价快照"
        [TABLE_HEAD: th_currency]
          CONTENT: "币种"
        [TABLE_HEAD: th_inventory_count]
          CONTENT: "可售库存快照"
        [TABLE_HEAD: th_cancellation_policy]
          CONTENT: "取消规则快照"
        [TABLE_HEAD: th_guarantee_policy]
          CONTENT: "担保规则快照"
        [TABLE_HEAD: th_sale_status]
          CONTENT: "可售状态"
    [TABLE_BODY: hotel_offer_table_body]
      [FOR: row in rows]
        [TABLE_ROW: hotel_offer_row]
          [TABLE_CELL: td_tenant_id]
            CONTENT: "{{row.tenant_id|}}"
          [TABLE_CELL: td_host_shop_id]
            CONTENT: "{{row.host_shop_id|}}"
          [TABLE_CELL: td_supplier_code]
            CONTENT: "{{row.supplier_code|}}"
          [TABLE_CELL: td_hotel_code]
            CONTENT: "{{row.hotel_code|}}"
          [TABLE_CELL: td_hotel_name]
            CONTENT: "{{row.hotel_name|}}"
          [TABLE_CELL: td_city_code]
            CONTENT: "{{row.city_code|}}"
          [TABLE_CELL: td_room_type_code]
            CONTENT: "{{row.room_type_code|}}"
          [TABLE_CELL: td_rate_plan_code]
            CONTENT: "{{row.rate_plan_code|}}"
          [TABLE_CELL: td_checkin_date]
            CONTENT: "{{row.checkin_date|}}"
          [TABLE_CELL: td_checkout_date]
            CONTENT: "{{row.checkout_date|}}"
          [TABLE_CELL: td_listed_price]
            CONTENT: "{{row.listed_price|}}"
          [TABLE_CELL: td_settlement_price]
            CONTENT: "{{row.settlement_price|}}"
          [TABLE_CELL: td_currency]
            CONTENT: "{{row.currency|}}"
          [TABLE_CELL: td_inventory_count]
            CONTENT: "{{row.inventory_count|}}"
          [TABLE_CELL: td_cancellation_policy]
            CONTENT: "{{row.cancellation_policy|}}"
          [TABLE_CELL: td_guarantee_policy]
            CONTENT: "{{row.guarantee_policy|}}"
          [TABLE_CELL: td_sale_status]
            [BADGE: badge_sale_status]
              CONTENT: "{{row.sale_status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: hotel_offer_no_data]
      ATTR: Description("暂无酒店可售 offer，承载房型、价计划、价态和可售规则快照数据")
  [/IF]
