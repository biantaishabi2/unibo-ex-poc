[PAGE: train_offer_detail]
  ATTR: Title("TrainOffer 详情")

  [BREADCRUMB: train_offer_breadcrumb]
    [BREADCRUMB_LIST: train_offer_bc_list]
      [BREADCRUMB_ITEM: train_offer_bc_list_item]
        [BREADCRUMB_LINK: train_offer_bc_link]
          ATTR: Patch("/travel/train_offer")
          CONTENT: "TrainOffer 列表"
      [BREADCRUMB_SEPARATOR: train_offer_bc_sep]
      [BREADCRUMB_ITEM: train_offer_bc_current_item]
        [BREADCRUMB_PAGE: train_offer_bc_current]
          CONTENT: "{{record.supplier_code|详情}}"

  [SECTION: train_offer_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: train_offer_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: train_offer_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.supplier_code|}}"
      [BADGE: train_offer_status_badge]
        CONTENT: "{{record.inventory_status|}}"
    [FLEX: train_offer_actions]
      { Gap: 2 }
      [BUTTON: train_offer_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"
      [BUTTON: train_offer_action_activate]
        ATTR: Variant("secondary"), Click("action_activate")
        CONTENT: "activate"
      [BUTTON: train_offer_action_deactivate]
        ATTR: Variant("secondary"), Click("action_deactivate")
        CONTENT: "deactivate"
      [BUTTON: train_offer_action_expire]
        ATTR: Variant("secondary"), Click("action_expire")
        CONTENT: "expire"
      [BUTTON: train_offer_delete_btn]
        ATTR: Variant("danger"), Click("action_destroy")
        CONTENT: "删除"

  [CARD: train_offer_info_card]
    [CARD_HEADER: train_offer_info_header]
      [CARD_TITLE: train_offer_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: train_offer_info_content]
      [IF: !editing]
        [GRID: train_offer_info_grid]
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
          [FLEX: field_train_no]
            [TEXT: label_train_no]
              ATTR: Variant("muted")
              CONTENT: "车次号"
            [TEXT: value_train_no]
              CONTENT: "{{record.train_no|}}"
          [FLEX: field_departure_station_code]
            [TEXT: label_departure_station_code]
              ATTR: Variant("muted")
              CONTENT: "出发站编码"
            [TEXT: value_departure_station_code]
              CONTENT: "{{record.departure_station_code|}}"
          [FLEX: field_departure_station_name]
            [TEXT: label_departure_station_name]
              ATTR: Variant("muted")
              CONTENT: "出发站名称"
            [TEXT: value_departure_station_name]
              CONTENT: "{{record.departure_station_name|}}"
          [FLEX: field_arrival_station_code]
            [TEXT: label_arrival_station_code]
              ATTR: Variant("muted")
              CONTENT: "到达站编码"
            [TEXT: value_arrival_station_code]
              CONTENT: "{{record.arrival_station_code|}}"
          [FLEX: field_arrival_station_name]
            [TEXT: label_arrival_station_name]
              ATTR: Variant("muted")
              CONTENT: "到达站名称"
            [TEXT: value_arrival_station_name]
              CONTENT: "{{record.arrival_station_name|}}"
          [FLEX: field_travel_date]
            [TEXT: label_travel_date]
              ATTR: Variant("muted")
              CONTENT: "乘车日期"
            [TEXT: value_travel_date]
              CONTENT: "{{record.travel_date|}}"
          [FLEX: field_departure_at]
            [TEXT: label_departure_at]
              ATTR: Variant("muted")
              CONTENT: "发车时间"
            [TEXT: value_departure_at]
              CONTENT: "{{record.departure_at|}}"
          [FLEX: field_arrival_at]
            [TEXT: label_arrival_at]
              ATTR: Variant("muted")
              CONTENT: "到达时间"
            [TEXT: value_arrival_at]
              CONTENT: "{{record.arrival_at|}}"
          [FLEX: field_seat_class]
            [TEXT: label_seat_class]
              ATTR: Variant("muted")
              CONTENT: "席别名称"
            [TEXT: value_seat_class]
              CONTENT: "{{record.seat_class|}}"
          [FLEX: field_seat_code]
            [TEXT: label_seat_code]
              ATTR: Variant("muted")
              CONTENT: "席别编码"
            [TEXT: value_seat_code]
              CONTENT: "{{record.seat_code|}}"
          [FLEX: field_is_no_seat]
            [TEXT: label_is_no_seat]
              ATTR: Variant("muted")
              CONTENT: "是否无座票"
            [BADGE: value_is_no_seat]
              CONTENT: "{{record.is_no_seat|}}"
          [FLEX: field_inventory_status]
            [TEXT: label_inventory_status]
              ATTR: Variant("muted")
              CONTENT: "余票或候补可用状态"
            [BADGE: value_inventory_status]
              CONTENT: "{{record.inventory_status|}}"
          [FLEX: field_waitlist_supported]
            [TEXT: label_waitlist_supported]
              ATTR: Variant("muted")
              CONTENT: "是否支持候补"
            [BADGE: value_waitlist_supported]
              CONTENT: "{{record.waitlist_supported|}}"
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
          [FLEX: field_booking_rules_snapshot]
            [TEXT: label_booking_rules_snapshot]
              ATTR: Variant("muted")
              CONTENT: "预订规则快照"
            [TEXT: value_booking_rules_snapshot]
              CONTENT: "{{record.booking_rules_snapshot|}}"
          [FLEX: field_change_rules_snapshot]
            [TEXT: label_change_rules_snapshot]
              ATTR: Variant("muted")
              CONTENT: "改签规则快照"
            [TEXT: value_change_rules_snapshot]
              CONTENT: "{{record.change_rules_snapshot|}}"
          [FLEX: field_refund_rules_snapshot]
            [TEXT: label_refund_rules_snapshot]
              ATTR: Variant("muted")
              CONTENT: "退票规则快照"
            [TEXT: value_refund_rules_snapshot]
              CONTENT: "{{record.refund_rules_snapshot|}}"
          [FLEX: field_sale_status]
            [TEXT: label_sale_status]
              ATTR: Variant("muted")
              CONTENT: "可售状态"
            [BADGE: value_sale_status]
              CONTENT: "{{record.sale_status|}}"
      [ELSE]
        [FORM: train_offer_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: train_offer_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_tenant_id]
              ATTR: Name("tenant_id"), Label("tenant_id"), Placeholder("请输入tenant_id"), Required("true")
            [INPUT: form_host_shop_id]
              ATTR: Name("host_shop_id"), Label("宿主商城 ID，仅用于宿主侧隔离和桥接上下文"), Placeholder("请输入宿主商城 ID，仅用于宿主侧隔离和桥接上下文")
            [INPUT: form_supplier_code]
              ATTR: Name("supplier_code"), Label("供应商编码"), Placeholder("请输入供应商编码"), Required("true")
            [INPUT: form_train_no]
              ATTR: Name("train_no"), Label("车次号"), Placeholder("请输入车次号"), Required("true")
            [INPUT: form_departure_station_code]
              ATTR: Name("departure_station_code"), Label("出发站编码"), Placeholder("请输入出发站编码"), Required("true")
            [INPUT: form_departure_station_name]
              ATTR: Name("departure_station_name"), Label("出发站名称"), Placeholder("请输入出发站名称"), Required("true")
            [INPUT: form_arrival_station_code]
              ATTR: Name("arrival_station_code"), Label("到达站编码"), Placeholder("请输入到达站编码"), Required("true")
            [INPUT: form_arrival_station_name]
              ATTR: Name("arrival_station_name"), Label("到达站名称"), Placeholder("请输入到达站名称"), Required("true")
            [INPUT: form_travel_date]
              ATTR: Name("travel_date"), Label("乘车日期"), Placeholder("请输入乘车日期"), Required("true")
            [INPUT: form_departure_at]
              ATTR: Name("departure_at"), Label("发车时间"), Placeholder("请输入发车时间"), Required("true")
            [INPUT: form_arrival_at]
              ATTR: Name("arrival_at"), Label("到达时间"), Placeholder("请输入到达时间"), Required("true")
            [INPUT: form_seat_class]
              ATTR: Name("seat_class"), Label("席别名称"), Placeholder("请输入席别名称"), Required("true")
            [INPUT: form_seat_code]
              ATTR: Name("seat_code"), Label("席别编码"), Placeholder("请输入席别编码"), Required("true")
            [SWITCH: form_is_no_seat]
              ATTR: Name("is_no_seat"), Label("是否无座票")
            [SELECT: form_inventory_status]
              ATTR: Name("inventory_status"), Label("余票或候补可用状态")
            [SWITCH: form_waitlist_supported]
              ATTR: Name("waitlist_supported"), Label("是否支持候补")
            [INPUT: form_listed_price]
              ATTR: Name("listed_price"), Label("对客展示价快照"), Placeholder("请输入对客展示价快照"), Required("true")
            [INPUT: form_settlement_price]
              ATTR: Name("settlement_price"), Label("结算价快照"), Placeholder("请输入结算价快照")
            [INPUT: form_currency]
              ATTR: Name("currency"), Label("currency"), Placeholder("请输入currency")
            [TEXTAREA: form_booking_rules_snapshot]
              ATTR: Name("booking_rules_snapshot"), Label("预订规则快照"), Placeholder("请输入预订规则快照")
            [TEXTAREA: form_change_rules_snapshot]
              ATTR: Name("change_rules_snapshot"), Label("改签规则快照"), Placeholder("请输入改签规则快照")
            [TEXTAREA: form_refund_rules_snapshot]
              ATTR: Name("refund_rules_snapshot"), Label("退票规则快照"), Placeholder("请输入退票规则快照")
            [SELECT: form_sale_status]
              ATTR: Name("sale_status"), Label("可售状态")
          [FLEX: train_offer_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: train_offer_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: train_offer_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
