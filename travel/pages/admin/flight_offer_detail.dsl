[PAGE: flight_offer_detail]
  META: Entity("FlightOffer"), Domain("Travel")
  ATTR: Title("FlightOffer 详情")

  [BREADCRUMB: flight_offer_breadcrumb]
    [BREADCRUMB_LIST: flight_offer_bc_list]
      [BREADCRUMB_ITEM: flight_offer_bc_list_item]
        [BREADCRUMB_LINK: flight_offer_bc_link]
          ATTR: Patch("/travel/flight_offer")
          CONTENT: "FlightOffer 列表"
      [BREADCRUMB_SEPARATOR: flight_offer_bc_sep]
      [BREADCRUMB_ITEM: flight_offer_bc_current_item]
        [BREADCRUMB_PAGE: flight_offer_bc_current]
          CONTENT: "{{record.supplier_code|详情}}"

  [SECTION: flight_offer_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: flight_offer_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: flight_offer_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.supplier_code|}}"
      [BADGE: flight_offer_status_badge]
        CONTENT: "{{record.sale_status|}}"
    [FLEX: flight_offer_actions]
      { Gap: 2 }
      [BUTTON: flight_offer_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"
      [BUTTON: flight_offer_action_activate]
        ATTR: Variant("secondary"), Click("action_activate")
        CONTENT: "activate"
      [BUTTON: flight_offer_action_deactivate]
        ATTR: Variant("secondary"), Click("action_deactivate")
        CONTENT: "deactivate"
      [BUTTON: flight_offer_action_expire]
        ATTR: Variant("secondary"), Click("action_expire")
        CONTENT: "expire"
      [BUTTON: flight_offer_delete_btn]
        ATTR: Variant("danger"), Click("action_destroy")
        CONTENT: "删除"

  [CARD: flight_offer_info_card]
    [CARD_HEADER: flight_offer_info_header]
      [CARD_TITLE: flight_offer_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: flight_offer_info_content]
      [IF: !editing]
        [GRID: flight_offer_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_tenant_id]
            [TEXT: label_tenant_id]
              ATTR: Variant("muted")
              CONTENT: "tenant_id"
            [TEXT: value_tenant_id]
              CONTENT: "{{record.tenant_id|}}"
          [FLEX: field_host_shop_id]
            [TEXT: label_host_shop_id]
              ATTR: Variant("muted")
              CONTENT: "宿主商城 ID，仅用于宿主侧隔离和桥接上下文"
            [TEXT: value_host_shop_id]
              CONTENT: "{{record.host_shop_id|}}"
          [FLEX: field_supplier_code]
            [TEXT: label_supplier_code]
              ATTR: Variant("muted")
              CONTENT: "供应商编码"
            [TEXT: value_supplier_code]
              CONTENT: "{{record.supplier_code|}}"
          [FLEX: field_itinerary_code]
            [TEXT: label_itinerary_code]
              ATTR: Variant("muted")
              CONTENT: "行程编码"
            [TEXT: value_itinerary_code]
              CONTENT: "{{record.itinerary_code|}}"
          [FLEX: field_flight_no]
            [TEXT: label_flight_no]
              ATTR: Variant("muted")
              CONTENT: "航班号"
            [TEXT: value_flight_no]
              CONTENT: "{{record.flight_no|}}"
          [FLEX: field_departure_airport_code]
            [TEXT: label_departure_airport_code]
              ATTR: Variant("muted")
              CONTENT: "出发机场编码"
            [TEXT: value_departure_airport_code]
              CONTENT: "{{record.departure_airport_code|}}"
          [FLEX: field_arrival_airport_code]
            [TEXT: label_arrival_airport_code]
              ATTR: Variant("muted")
              CONTENT: "到达机场编码"
            [TEXT: value_arrival_airport_code]
              CONTENT: "{{record.arrival_airport_code|}}"
          [FLEX: field_departure_at]
            [TEXT: label_departure_at]
              ATTR: Variant("muted")
              CONTENT: "起飞时间"
            [TEXT: value_departure_at]
              CONTENT: "{{record.departure_at|}}"
          [FLEX: field_arrival_at]
            [TEXT: label_arrival_at]
              ATTR: Variant("muted")
              CONTENT: "到达时间"
            [TEXT: value_arrival_at]
              CONTENT: "{{record.arrival_at|}}"
          [FLEX: field_cabin_class]
            [TEXT: label_cabin_class]
              ATTR: Variant("muted")
              CONTENT: "舱等"
            [TEXT: value_cabin_class]
              CONTENT: "{{record.cabin_class|}}"
          [FLEX: field_fare_family]
            [TEXT: label_fare_family]
              ATTR: Variant("muted")
              CONTENT: "运价族"
            [TEXT: value_fare_family]
              CONTENT: "{{record.fare_family|}}"
          [FLEX: field_listed_price]
            [TEXT: label_listed_price]
              ATTR: Variant("muted")
              CONTENT: "对客展示价快照"
            [TEXT: value_listed_price]
              CONTENT: "{{record.listed_price|}}"
          [FLEX: field_settlement_price]
            [TEXT: label_settlement_price]
              ATTR: Variant("muted")
              CONTENT: "结算价快照"
            [TEXT: value_settlement_price]
              CONTENT: "{{record.settlement_price|}}"
          [FLEX: field_currency]
            [TEXT: label_currency]
              ATTR: Variant("muted")
              CONTENT: "currency"
            [TEXT: value_currency]
              CONTENT: "{{record.currency|}}"
          [FLEX: field_seats_available]
            [TEXT: label_seats_available]
              ATTR: Variant("muted")
              CONTENT: "可售座位快照"
            [TEXT: value_seats_available]
              CONTENT: "{{record.seats_available|}}"
          [FLEX: field_baggage_policy]
            [TEXT: label_baggage_policy]
              ATTR: Variant("muted")
              CONTENT: "行李规则快照"
            [TEXT: value_baggage_policy]
              CONTENT: "{{record.baggage_policy|}}"
          [FLEX: field_refund_change_policy]
            [TEXT: label_refund_change_policy]
              ATTR: Variant("muted")
              CONTENT: "退改规则快照"
            [TEXT: value_refund_change_policy]
              CONTENT: "{{record.refund_change_policy|}}"
          [FLEX: field_sale_status]
            [TEXT: label_sale_status]
              ATTR: Variant("muted")
              CONTENT: "sale_status"
            [BADGE: value_sale_status]
              CONTENT: "{{record.sale_status|}}"
      [ELSE]
        [FORM: flight_offer_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: flight_offer_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_tenant_id]
              ATTR: Name("tenant_id"), Label("tenant_id"), Placeholder("请输入tenant_id"), Required("true")
            [INPUT: form_host_shop_id]
              ATTR: Name("host_shop_id"), Label("宿主商城 ID，仅用于宿主侧隔离和桥接上下文"), Placeholder("请输入宿主商城 ID，仅用于宿主侧隔离和桥接上下文")
            [INPUT: form_supplier_code]
              ATTR: Name("supplier_code"), Label("供应商编码"), Placeholder("请输入供应商编码"), Required("true")
            [INPUT: form_itinerary_code]
              ATTR: Name("itinerary_code"), Label("行程编码"), Placeholder("请输入行程编码"), Required("true")
            [INPUT: form_flight_no]
              ATTR: Name("flight_no"), Label("航班号"), Placeholder("请输入航班号"), Required("true")
            [INPUT: form_departure_airport_code]
              ATTR: Name("departure_airport_code"), Label("出发机场编码"), Placeholder("请输入出发机场编码"), Required("true")
            [INPUT: form_arrival_airport_code]
              ATTR: Name("arrival_airport_code"), Label("到达机场编码"), Placeholder("请输入到达机场编码"), Required("true")
            [INPUT: form_departure_at]
              ATTR: Name("departure_at"), Label("起飞时间"), Placeholder("请输入起飞时间"), Required("true")
            [INPUT: form_arrival_at]
              ATTR: Name("arrival_at"), Label("到达时间"), Placeholder("请输入到达时间"), Required("true")
            [INPUT: form_cabin_class]
              ATTR: Name("cabin_class"), Label("舱等"), Placeholder("请输入舱等"), Required("true")
            [INPUT: form_fare_family]
              ATTR: Name("fare_family"), Label("运价族"), Placeholder("请输入运价族")
            [INPUT: form_listed_price]
              ATTR: Name("listed_price"), Label("对客展示价快照"), Placeholder("请输入对客展示价快照"), Required("true")
            [INPUT: form_settlement_price]
              ATTR: Name("settlement_price"), Label("结算价快照"), Placeholder("请输入结算价快照")
            [INPUT: form_currency]
              ATTR: Name("currency"), Label("currency"), Placeholder("请输入currency")
            [INPUT: form_seats_available]
              ATTR: Name("seats_available"), Label("可售座位快照"), Placeholder("请输入可售座位快照")
            [TEXTAREA: form_baggage_policy]
              ATTR: Name("baggage_policy"), Label("行李规则快照"), Placeholder("请输入行李规则快照")
            [TEXTAREA: form_refund_change_policy]
              ATTR: Name("refund_change_policy"), Label("退改规则快照"), Placeholder("请输入退改规则快照")
            [SELECT: form_sale_status]
              ATTR: Name("sale_status"), Label("sale_status")
              BIND: Enum("FlightOffer", "sale_status")
          [FLEX: flight_offer_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: flight_offer_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: flight_offer_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
