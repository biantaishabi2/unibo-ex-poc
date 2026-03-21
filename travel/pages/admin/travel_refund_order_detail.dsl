[PAGE: travel_refund_order_detail]
  META: Entity("TravelRefundOrder"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("TravelRefundOrder 详情")

  [BREADCRUMB: travel_refund_order_breadcrumb]
    [BREADCRUMB_LIST: travel_refund_order_bc_list]
      [BREADCRUMB_ITEM: travel_refund_order_bc_list_item]
        [BREADCRUMB_LINK: travel_refund_order_bc_link]
          ATTR: Patch("/travel/travel_refund_order")
          CONTENT: "TravelRefundOrder 列表"
      [BREADCRUMB_SEPARATOR: travel_refund_order_bc_sep]
      [BREADCRUMB_ITEM: travel_refund_order_bc_current_item]
        [BREADCRUMB_PAGE: travel_refund_order_bc_current]
          CONTENT: "{{record.id|详情}}"

  [SECTION: travel_refund_order_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: travel_refund_order_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: travel_refund_order_detail_title]
        ATTR: Variant("title")
        CONTENT: "退票单详情"
      [BADGE: travel_refund_order_status_badge]
        CONTENT: "{{record.status|}}"

  [CARD: travel_refund_order_info_card]
    [CARD_HEADER: travel_refund_order_info_header]
      [CARD_TITLE: travel_refund_order_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: travel_refund_order_info_content]
      [GRID: travel_refund_order_info_grid]
        { Columns: 2, Gap: 4 }
        [FLEX: field_original_order_id]
          [TEXT: label_original_order_id]
            ATTR: Variant("muted")
            CONTENT: "原订单"
          [TEXT: value_original_order_id]
            CONTENT: "{{record.original_order_id|}}"
        [FLEX: field_refund_reason]
          [TEXT: label_refund_reason]
            ATTR: Variant("muted")
            CONTENT: "退票原因"
          [TEXT: value_refund_reason]
            CONTENT: "{{record.refund_reason|}}"
        [FLEX: field_refund_fee]
          [TEXT: label_refund_fee]
            ATTR: Variant("muted")
            CONTENT: "退票手续费"
          [TEXT: value_refund_fee]
            CONTENT: "{{record.refund_fee|}}"
        [FLEX: field_refund_amount]
          [TEXT: label_refund_amount]
            ATTR: Variant("muted")
            CONTENT: "实退金额"
          [TEXT: value_refund_amount]
            CONTENT: "{{record.refund_amount|}}"
        [FLEX: field_status]
          [TEXT: label_status]
            ATTR: Variant("muted")
            CONTENT: "状态"
          [BADGE: value_status]
            CONTENT: "{{record.status|}}"
