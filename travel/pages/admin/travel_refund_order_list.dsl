[PAGE: travel_refund_order_list]
  META: Entity("TravelRefundOrder"), Domain("Travel")
  ATTR: Title("TravelRefundOrder 列表")

  [SECTION: travel_refund_order_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: travel_refund_order_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TravelRefundOrder 列表}}"
    [BUTTON: travel_refund_order_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: travel_refund_order_filter_card]
    [CARD_CONTENT: travel_refund_order_filter_content]
      [FLEX: travel_refund_order_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_status]
          ATTR: Name("status"), Label("状态")
          BIND: Enum("TravelRefundOrder", "status")
        [BUTTON: travel_refund_order_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: travel_refund_order_table]
    [TABLE_HEADER: travel_refund_order_table_header]
      [TABLE_ROW: travel_refund_order_header_row]
        [TABLE_HEAD: th_original_order_id]
          CONTENT: "原订单"
        [TABLE_HEAD: th_refund_reason]
          CONTENT: "退票原因"
        [TABLE_HEAD: th_refund_fee]
          CONTENT: "退票手续费"
        [TABLE_HEAD: th_refund_amount]
          CONTENT: "实退金额"
        [TABLE_HEAD: th_status]
          CONTENT: "状态"
    [TABLE_BODY: travel_refund_order_table_body]
      [FOR: row in rows]
        [TABLE_ROW: travel_refund_order_row]
          [TABLE_CELL: td_original_order_id]
            CONTENT: "{{row.original_order_id|}}"
          [TABLE_CELL: td_refund_reason]
            CONTENT: "{{row.refund_reason|}}"
          [TABLE_CELL: td_refund_fee]
            CONTENT: "{{row.refund_fee|}}"
          [TABLE_CELL: td_refund_amount]
            CONTENT: "{{row.refund_amount|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: travel_refund_order_no_data]
      ATTR: Description("暂无退票单数据")
  [/IF]
