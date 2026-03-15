[PAGE: flight_detail]
  ATTR: Title("航班详情")

  [SECTION: route_summary]
    { Background: "primary", Padding: 4 }
    [FLEX: route_display]
      { Justify: "Between", Align: "Center" }
      [STACK: departure_info]
        { Gap: 0, Align: "Center" }
        [TEXT: departure_time]
          ATTR: Variant("h1"), Weight("bold"), Color("white")
          CONTENT: "{{flight_offer.departure_at|}}"
        [TEXT: departure_code]
          ATTR: Variant("caption"), Color("white")
          CONTENT: "{{flight_offer.departure_airport_code|}}"
      [STACK: flight_indicator]
        { Gap: 0, Align: "Center" }
        [ICON: plane_icon]
          ATTR: Name("plane"), Color("white")
      [STACK: arrival_info]
        { Gap: 0, Align: "Center" }
        [TEXT: arrival_time]
          ATTR: Variant("h1"), Weight("bold"), Color("white")
          CONTENT: "{{flight_offer.arrival_at|}}"
        [TEXT: arrival_code]
          ATTR: Variant("caption"), Color("white")
          CONTENT: "{{flight_offer.arrival_airport_code|}}"

  [SECTION: flight_info_section]
    [CARD: flight_info_card]
      [CARD_HEADER: flight_info_header]
        [TEXT: info_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "航班信息"
      [CARD_CONTENT: flight_info_content]
        [GRID: info_grid]
          { Columns: 2, Gap: 3 }
          [TEXT: fields_display]
            [TEXT: flight_no]
              ATTR: Label("航班号")
              CONTENT: "{{@flight_offer.flight_no|}}"
            [TEXT: cabin_class]
              ATTR: Label("舱等")
              CONTENT: "{{@flight_offer.cabin_class|}}"
            [TEXT: fare_family]
              ATTR: Label("运价族")
              CONTENT: "{{@flight_offer.fare_family|}}"
            [TEXT: listed_price]
              ATTR: Label("对客展示价快照")
              CONTENT: "{{@flight_offer.listed_price|}}"
            [TEXT: settlement_price]
              ATTR: Label("结算价快照")
              CONTENT: "{{@flight_offer.settlement_price|}}"
            [TEXT: currency]
              ATTR: Label("currency")
              CONTENT: "{{@flight_offer.currency|}}"
            [TEXT: seats_available]
              ATTR: Label("可售座位快照")
              CONTENT: "{{@flight_offer.seats_available|}}"
            [TEXT: baggage_policy]
              ATTR: Label("行李规则快照")
              CONTENT: "{{@flight_offer.baggage_policy|}}"
            [TEXT: refund_change_policy]
              ATTR: Label("退改规则快照")
              CONTENT: "{{@flight_offer.refund_change_policy|}}"

  [SECTION: status_section]
    [TEXT: status_display]
      [BADGE: flight_offer_lifecycle_status]
        ATTR: Label("机票 offer 生命周期")
        CONTENT: "{{@flight_offer.flight_offer_lifecycle|}}"
      [BUTTON: wf_flight_offer_lifecycle_create]
        ATTR: Click("flight_offer_create")
        CONTENT: "create"
      [BUTTON: wf_flight_offer_lifecycle_update]
        ATTR: Click("flight_offer_update")
        CONTENT: "update"
      [BUTTON: wf_flight_offer_lifecycle_activate]
        ATTR: Click("flight_offer_activate")
        CONTENT: "activate"
      [BUTTON: wf_flight_offer_lifecycle_deactivate]
        ATTR: Click("flight_offer_deactivate")
        CONTENT: "deactivate"
      [BUTTON: wf_flight_offer_lifecycle_expire]
        ATTR: Click("flight_offer_expire")
        CONTENT: "expire"
      [BUTTON: wf_flight_offer_lifecycle_destroy]
        ATTR: Click("flight_offer_destroy")
        CONTENT: "destroy"

  [SECTION: actions_section]
    [TEXT: offer_actions]
      [BUTTON: activate]
        ATTR: Click("flight_offer_activate")
        CONTENT: "activate"
      [BUTTON: deactivate]
        ATTR: Click("flight_offer_deactivate")
        CONTENT: "deactivate"
      [BUTTON: expire]
        ATTR: Click("flight_offer_expire")
        CONTENT: "expire"

  [SECTION: orders_section]
    [TEXT: orders_table]
      [TABLE_HEADER: orders_header]
        [TEXT: th_tenant_id]
          CONTENT: "tenant_id"
        [TEXT: th_host_shop_id]
          CONTENT: "宿主商城 ID，用于 sidecar 对接上下文"
        [TEXT: th_host_member_id]
          CONTENT: "宿主会员标识，来自 shop caller context"
        [TEXT: th_host_enterprise_id]
          CONTENT: "宿主企业标识，来自 shop caller context"
        [TEXT: th_order_no]
          CONTENT: "订单号"
        [TEXT: th_product_type]
          CONTENT: "商品类型"
        [TEXT: th_booking_mode]
          CONTENT: "train 订单预订模式"
        [TEXT: th_contact_name]
          CONTENT: "contact_name"
        [TEXT: th_contact_phone]
          CONTENT: "contact_phone"
        [TEXT: th_traveler_count]
          CONTENT: "出行人数量"
        [TEXT: th_total_amount]
          CONTENT: "订单总金额"
        [TEXT: th_points_to_use]
          CONTENT: "计划使用的积分数量"
        [TEXT: th_points_deduction_amount]
          CONTENT: "积分抵现金额"
        [TEXT: th_recommended_payment_method]
          CONTENT: "宿主 quote 返回的推荐支付方式"
        [TEXT: th_currency]
          CONTENT: "currency"
        [TEXT: th_status]
          CONTENT: "status"
        [TEXT: th_change_status]
          CONTENT: "change_status"
        [TEXT: th_waitlist_status]
          CONTENT: "waitlist_status"
        [TEXT: th_original_order_ref]
          CONTENT: "改签链路引用的原订单号或原票号"
        [TEXT: th_ticket_passenger_infos]
          CONTENT: "乘车人信息快照"
        [TEXT: th_seat_selection_snapshot]
          CONTENT: "选座与席别偏好快照"
        [TEXT: th_supplier_order_ref]
          CONTENT: "供应商订单号"
        [TEXT: th_payment_external_ref]
          CONTENT: "宿主支付侧外部支付流水号"
      [TABLE_BODY: orders_body]
        [FOR: travel_order in @flight_offer.orders]
          [TEXT: tenant_id]
            CONTENT: "{{@travel_order.tenant_id|}}"
          [TEXT: host_shop_id]
            CONTENT: "{{@travel_order.host_shop_id|}}"
          [TEXT: host_member_id]
            CONTENT: "{{@travel_order.host_member_id|}}"
          [TEXT: host_enterprise_id]
            CONTENT: "{{@travel_order.host_enterprise_id|}}"
          [TEXT: order_no]
            CONTENT: "{{@travel_order.order_no|}}"
          [BADGE: product_type]
            CONTENT: "{{@travel_order.product_type|}}"
          [BADGE: booking_mode]
            CONTENT: "{{@travel_order.booking_mode|}}"
          [TEXT: contact_name]
            CONTENT: "{{@travel_order.contact_name|}}"
          [TEXT: contact_phone]
            CONTENT: "{{@travel_order.contact_phone|}}"
          [TEXT: traveler_count]
            CONTENT: "{{@travel_order.traveler_count|}}"
          [TEXT: total_amount]
            CONTENT: "{{@travel_order.total_amount|}}"
          [TEXT: points_to_use]
            CONTENT: "{{@travel_order.points_to_use|}}"
          [TEXT: points_deduction_amount]
            CONTENT: "{{@travel_order.points_deduction_amount|}}"
          [TEXT: recommended_payment_method]
            CONTENT: "{{@travel_order.recommended_payment_method|}}"
          [TEXT: currency]
            CONTENT: "{{@travel_order.currency|}}"
          [BADGE: status]
            CONTENT: "{{@travel_order.status|}}"
          [BADGE: change_status]
            CONTENT: "{{@travel_order.change_status|}}"
          [BADGE: waitlist_status]
            CONTENT: "{{@travel_order.waitlist_status|}}"
          [TEXT: original_order_ref]
            CONTENT: "{{@travel_order.original_order_ref|}}"
          [TEXT: ticket_passenger_infos]
            CONTENT: "{{@travel_order.ticket_passenger_infos|}}"
          [TEXT: seat_selection_snapshot]
            CONTENT: "{{@travel_order.seat_selection_snapshot|}}"
          [TEXT: supplier_order_ref]
            CONTENT: "{{@travel_order.supplier_order_ref|}}"
          [TEXT: payment_external_ref]
            CONTENT: "{{@travel_order.payment_external_ref|}}"
        [/FOR]
