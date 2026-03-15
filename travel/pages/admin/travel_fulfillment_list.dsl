[PAGE: travel_fulfillment_list]
  ATTR: Title("TravelFulfillment 列表")

  [SECTION: travel_fulfillment_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: travel_fulfillment_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TravelFulfillment 列表}}"
    [BUTTON: travel_fulfillment_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: travel_fulfillment_filter_card]
    [CARD_CONTENT: travel_fulfillment_filter_content]
      [FLEX: travel_fulfillment_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_fulfillment_type]
          ATTR: Name("fulfillment_type"), Label("fulfillment_type")
        [SELECT: filter_status]
          ATTR: Name("status"), Label("status")
        [SELECT: filter_waitlist_result]
          ATTR: Name("waitlist_result"), Label("train 候补兑现结果")
        [SELECT: filter_change_result]
          ATTR: Name("change_result"), Label("train 改签结果")
        [SELECT: filter_boarding_status]
          ATTR: Name("boarding_status"), Label("train 乘车状态")
        [INPUT: filter_used_at_from]
          ATTR: Name("used_at_from"), Label("实际使用时间 起")
        [INPUT: filter_used_at_to]
          ATTR: Name("used_at_to"), Label("实际使用时间 止")
        [BUTTON: travel_fulfillment_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: travel_fulfillment_table]
    [TABLE_HEADER: travel_fulfillment_table_header]
      [TABLE_ROW: travel_fulfillment_header_row]
        [TABLE_HEAD: th_tenant_id]
          CONTENT: "tenant_id"
        [TABLE_HEAD: th_fulfillment_type]
          CONTENT: "fulfillment_type"
        [TABLE_HEAD: th_status]
          CONTENT: "status"
        [TABLE_HEAD: th_supplier_booking_ref]
          CONTENT: "供应商预订号"
        [TABLE_HEAD: th_voucher_or_ticket_ref]
          CONTENT: "凭证号或票号"
        [TABLE_HEAD: th_ticket_refs]
          CONTENT: "多张票号、座席和乘客映射结果"
        [TABLE_HEAD: th_waitlist_result]
          CONTENT: "train 候补兑现结果"
        [TABLE_HEAD: th_change_result]
          CONTENT: "train 改签结果"
        [TABLE_HEAD: th_boarding_status]
          CONTENT: "train 乘车状态"
        [TABLE_HEAD: th_confirmation_payload]
          CONTENT: "确认结果快照"
        [TABLE_HEAD: th_failure_reason]
          CONTENT: "失败原因"
        [TABLE_HEAD: th_used_at]
          CONTENT: "实际使用时间"
    [TABLE_BODY: travel_fulfillment_table_body]
      [FOR: row in rows]
        [TABLE_ROW: travel_fulfillment_row]
          [TABLE_CELL: td_tenant_id]
            CONTENT: "{{row.tenant_id|}}"
          [TABLE_CELL: td_fulfillment_type]
            [BADGE: badge_fulfillment_type]
              CONTENT: "{{row.fulfillment_type|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
          [TABLE_CELL: td_supplier_booking_ref]
            CONTENT: "{{row.supplier_booking_ref|}}"
          [TABLE_CELL: td_voucher_or_ticket_ref]
            CONTENT: "{{row.voucher_or_ticket_ref|}}"
          [TABLE_CELL: td_ticket_refs]
            CONTENT: "{{row.ticket_refs|}}"
          [TABLE_CELL: td_waitlist_result]
            [BADGE: badge_waitlist_result]
              CONTENT: "{{row.waitlist_result|}}"
          [TABLE_CELL: td_change_result]
            [BADGE: badge_change_result]
              CONTENT: "{{row.change_result|}}"
          [TABLE_CELL: td_boarding_status]
            [BADGE: badge_boarding_status]
              CONTENT: "{{row.boarding_status|}}"
          [TABLE_CELL: td_confirmation_payload]
            CONTENT: "{{row.confirmation_payload|}}"
          [TABLE_CELL: td_failure_reason]
            CONTENT: "{{row.failure_reason|}}"
          [TABLE_CELL: td_used_at]
            CONTENT: "{{row.used_at|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: travel_fulfillment_no_data]
      ATTR: Description("暂无统一酒旅履约聚合，承接预订确认、发券出票、候补兑现、乘车使用和失败结果；可选关联 Delivery::Shipment数据")
  [/IF]
