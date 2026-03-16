[PAGE: travel_change_order_detail]
  ATTR: Title("TravelChangeOrder 详情")

  [BREADCRUMB: travel_change_order_breadcrumb]
    [BREADCRUMB_LIST: travel_change_order_bc_list]
      [BREADCRUMB_ITEM: travel_change_order_bc_list_item]
        [BREADCRUMB_LINK: travel_change_order_bc_link]
          ATTR: Patch("/travel/travel_change_order")
          CONTENT: "TravelChangeOrder 列表"
      [BREADCRUMB_SEPARATOR: travel_change_order_bc_sep]
      [BREADCRUMB_ITEM: travel_change_order_bc_current_item]
        [BREADCRUMB_PAGE: travel_change_order_bc_current]
          CONTENT: "{{record.id|详情}}"

  [SECTION: travel_change_order_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: travel_change_order_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: travel_change_order_detail_title]
        ATTR: Variant("title")
        CONTENT: "改签单详情"
      [BADGE: travel_change_order_status_badge]
        CONTENT: "{{record.status|}}"

  [CARD: travel_change_order_info_card]
    [CARD_HEADER: travel_change_order_info_header]
      [CARD_TITLE: travel_change_order_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: travel_change_order_info_content]
      [GRID: travel_change_order_info_grid]
        { Columns: 2, Gap: 4 }
        [FLEX: field_original_order_id]
          [TEXT: label_original_order_id]
            ATTR: Variant("muted")
            CONTENT: "原订单"
          [TEXT: value_original_order_id]
            CONTENT: "{{record.original_order_id|}}"
        [FLEX: field_change_reason]
          [TEXT: label_change_reason]
            ATTR: Variant("muted")
            CONTENT: "改签原因"
          [TEXT: value_change_reason]
            CONTENT: "{{record.change_reason|}}"
        [FLEX: field_price_difference]
          [TEXT: label_price_difference]
            ATTR: Variant("muted")
            CONTENT: "差价"
          [TEXT: value_price_difference]
            CONTENT: "{{record.price_difference|}}"
        [FLEX: field_change_fee]
          [TEXT: label_change_fee]
            ATTR: Variant("muted")
            CONTENT: "改签手续费"
          [TEXT: value_change_fee]
            CONTENT: "{{record.change_fee|}}"
        [FLEX: field_new_offer_id]
          [TEXT: label_new_offer_id]
            ATTR: Variant("muted")
            CONTENT: "新报价ID"
          [TEXT: value_new_offer_id]
            CONTENT: "{{record.new_offer_id|}}"
        [FLEX: field_status]
          [TEXT: label_status]
            ATTR: Variant("muted")
            CONTENT: "状态"
          [BADGE: value_status]
            CONTENT: "{{record.status|}}"
