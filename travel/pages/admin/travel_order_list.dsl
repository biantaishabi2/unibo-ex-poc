[PAGE: travel_order_list]
  ATTR: Title("TravelOrder 列表")

  [SECTION: travel_order_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: travel_order_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TravelOrder 列表}}"
    [BUTTON: travel_order_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: travel_order_filter_card]
    [CARD_CONTENT: travel_order_filter_content]
      [FLEX: travel_order_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_product_type]
          ATTR: Name("product_type"), Label("商品类型")
        [SELECT: filter_booking_mode]
          ATTR: Name("booking_mode"), Label("train 订单预订模式")
        [SELECT: filter_status]
          ATTR: Name("status"), Label("status")
        [SELECT: filter_change_status]
          ATTR: Name("change_status"), Label("change_status")
        [SELECT: filter_waitlist_status]
          ATTR: Name("waitlist_status"), Label("waitlist_status")
        [BUTTON: travel_order_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: travel_order_table]
    [TABLE_HEADER: travel_order_table_header]
      [TABLE_ROW: travel_order_header_row]
        [TABLE_HEAD: th_tenant_id]
          CONTENT: "tenant_id"
        [TABLE_HEAD: th_host_shop_id]
          CONTENT: "宿主商城 ID，用于 sidecar 对接上下文"
        [TABLE_HEAD: th_host_member_id]
          CONTENT: "宿主会员标识，来自 shop caller context"
        [TABLE_HEAD: th_host_enterprise_id]
          CONTENT: "宿主企业标识，来自 shop caller context"
        [TABLE_HEAD: th_order_no]
          CONTENT: "订单号"
        [TABLE_HEAD: th_product_type]
          CONTENT: "商品类型"
        [TABLE_HEAD: th_booking_mode]
          CONTENT: "train 订单预订模式"
        [TABLE_HEAD: th_contact_name]
          CONTENT: "contact_name"
        [TABLE_HEAD: th_contact_phone]
          CONTENT: "contact_phone"
        [TABLE_HEAD: th_traveler_count]
          CONTENT: "出行人数量"
        [TABLE_HEAD: th_total_amount]
          CONTENT: "订单总金额"
        [TABLE_HEAD: th_points_to_use]
          CONTENT: "计划使用的积分数量"
        [TABLE_HEAD: th_points_deduction_amount]
          CONTENT: "积分抵现金额"
        [TABLE_HEAD: th_recommended_payment_method]
          CONTENT: "宿主 quote 返回的推荐支付方式"
        [TABLE_HEAD: th_currency]
          CONTENT: "currency"
        [TABLE_HEAD: th_status]
          CONTENT: "status"
        [TABLE_HEAD: th_change_status]
          CONTENT: "change_status"
        [TABLE_HEAD: th_waitlist_status]
          CONTENT: "waitlist_status"
        [TABLE_HEAD: th_original_order_ref]
          CONTENT: "改签链路引用的原订单号或原票号"
        [TABLE_HEAD: th_ticket_passenger_infos]
          CONTENT: "乘车人信息快照"
        [TABLE_HEAD: th_seat_selection_snapshot]
          CONTENT: "选座与席别偏好快照"
        [TABLE_HEAD: th_supplier_order_ref]
          CONTENT: "供应商订单号"
        [TABLE_HEAD: th_payment_external_ref]
          CONTENT: "宿主支付侧外部支付流水号"
    [TABLE_BODY: travel_order_table_body]
      [FOR: row in rows]
        [TABLE_ROW: travel_order_row]
          [TABLE_CELL: td_tenant_id]
            CONTENT: "{{row.tenant_id|}}"
          [TABLE_CELL: td_host_shop_id]
            CONTENT: "{{row.host_shop_id|}}"
          [TABLE_CELL: td_host_member_id]
            CONTENT: "{{row.host_member_id|}}"
          [TABLE_CELL: td_host_enterprise_id]
            CONTENT: "{{row.host_enterprise_id|}}"
          [TABLE_CELL: td_order_no]
            CONTENT: "{{row.order_no|}}"
          [TABLE_CELL: td_product_type]
            [BADGE: badge_product_type]
              CONTENT: "{{row.product_type|}}"
          [TABLE_CELL: td_booking_mode]
            [BADGE: badge_booking_mode]
              CONTENT: "{{row.booking_mode|}}"
          [TABLE_CELL: td_contact_name]
            CONTENT: "{{row.contact_name|}}"
          [TABLE_CELL: td_contact_phone]
            CONTENT: "{{row.contact_phone|}}"
          [TABLE_CELL: td_traveler_count]
            CONTENT: "{{row.traveler_count|}}"
          [TABLE_CELL: td_total_amount]
            CONTENT: "{{row.total_amount|}}"
          [TABLE_CELL: td_points_to_use]
            CONTENT: "{{row.points_to_use|}}"
          [TABLE_CELL: td_points_deduction_amount]
            CONTENT: "{{row.points_deduction_amount|}}"
          [TABLE_CELL: td_recommended_payment_method]
            CONTENT: "{{row.recommended_payment_method|}}"
          [TABLE_CELL: td_currency]
            CONTENT: "{{row.currency|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
          [TABLE_CELL: td_change_status]
            [BADGE: badge_change_status]
              CONTENT: "{{row.change_status|}}"
          [TABLE_CELL: td_waitlist_status]
            [BADGE: badge_waitlist_status]
              CONTENT: "{{row.waitlist_status|}}"
          [TABLE_CELL: td_original_order_ref]
            CONTENT: "{{row.original_order_ref|}}"
          [TABLE_CELL: td_ticket_passenger_infos]
            CONTENT: "{{row.ticket_passenger_infos|}}"
          [TABLE_CELL: td_seat_selection_snapshot]
            CONTENT: "{{row.seat_selection_snapshot|}}"
          [TABLE_CELL: td_supplier_order_ref]
            CONTENT: "{{row.supplier_order_ref|}}"
          [TABLE_CELL: td_payment_external_ref]
            CONTENT: "{{row.payment_external_ref|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: travel_order_no_data]
      ATTR: Description("暂无统一酒旅订单，承接 hotel、flight、vacation、train 四类商品的下单和状态流转；通过跨域引用关联 Sales::Customer 和 Payment::Payment数据")
  [/IF]
