[PAGE: travel_change_order_list]
  ATTR: Title("TravelChangeOrder 列表")

  [SECTION: travel_change_order_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: travel_change_order_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TravelChangeOrder 列表}}"
    [BUTTON: travel_change_order_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: travel_change_order_filter_card]
    [CARD_CONTENT: travel_change_order_filter_content]
      [FLEX: travel_change_order_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_status]
          ATTR: Name("status"), Label("状态")
        [BUTTON: travel_change_order_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: travel_change_order_table]
    [TABLE_HEADER: travel_change_order_table_header]
      [TABLE_ROW: travel_change_order_header_row]
        [TABLE_HEAD: th_original_order_id]
          CONTENT: "原订单"
        [TABLE_HEAD: th_change_reason]
          CONTENT: "改签原因"
        [TABLE_HEAD: th_price_difference]
          CONTENT: "差价"
        [TABLE_HEAD: th_change_fee]
          CONTENT: "改签手续费"
        [TABLE_HEAD: th_new_offer_id]
          CONTENT: "新报价ID"
        [TABLE_HEAD: th_status]
          CONTENT: "状态"
    [TABLE_BODY: travel_change_order_table_body]
      [FOR: row in rows]
        [TABLE_ROW: travel_change_order_row]
          [TABLE_CELL: td_original_order_id]
            CONTENT: "{{row.original_order_id|}}"
          [TABLE_CELL: td_change_reason]
            CONTENT: "{{row.change_reason|}}"
          [TABLE_CELL: td_price_difference]
            CONTENT: "{{row.price_difference|}}"
          [TABLE_CELL: td_change_fee]
            CONTENT: "{{row.change_fee|}}"
          [TABLE_CELL: td_new_offer_id]
            CONTENT: "{{row.new_offer_id|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: travel_change_order_no_data]
      ATTR: Description("暂无改签单数据")
  [/IF]
