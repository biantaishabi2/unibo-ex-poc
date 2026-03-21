[PAGE: vacation_offer_detail]
  META: Entity("VacationOffer"), Domain("Travel")
  ATTR: Title("VacationOffer 详情")

  [BREADCRUMB: vacation_offer_breadcrumb]
    [BREADCRUMB_LIST: vacation_offer_bc_list]
      [BREADCRUMB_ITEM: vacation_offer_bc_list_item]
        [BREADCRUMB_LINK: vacation_offer_bc_link]
          ATTR: Patch("/travel/vacation_offer")
          CONTENT: "VacationOffer 列表"
      [BREADCRUMB_SEPARATOR: vacation_offer_bc_sep]
      [BREADCRUMB_ITEM: vacation_offer_bc_current_item]
        [BREADCRUMB_PAGE: vacation_offer_bc_current]
          CONTENT: "{{record.supplier_code|详情}}"

  [SECTION: vacation_offer_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: vacation_offer_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: vacation_offer_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.supplier_code|}}"
      [BADGE: vacation_offer_status_badge]
        CONTENT: "{{record.sale_status|}}"
    [FLEX: vacation_offer_actions]
      { Gap: 2 }
      [BUTTON: vacation_offer_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"
      [BUTTON: vacation_offer_action_activate]
        ATTR: Variant("secondary"), Click("action_activate")
        CONTENT: "activate"
      [BUTTON: vacation_offer_action_deactivate]
        ATTR: Variant("secondary"), Click("action_deactivate")
        CONTENT: "deactivate"
      [BUTTON: vacation_offer_action_expire]
        ATTR: Variant("secondary"), Click("action_expire")
        CONTENT: "expire"
      [BUTTON: vacation_offer_delete_btn]
        ATTR: Variant("danger"), Click("action_destroy")
        CONTENT: "删除"

  [CARD: vacation_offer_info_card]
    [CARD_HEADER: vacation_offer_info_header]
      [CARD_TITLE: vacation_offer_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: vacation_offer_info_content]
      [IF: !editing]
        [GRID: vacation_offer_info_grid]
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
          [FLEX: field_package_code]
            [TEXT: label_package_code]
              ATTR: Variant("muted")
              CONTENT: "套餐编码"
            [TEXT: value_package_code]
              CONTENT: "{{record.package_code|}}"
          [FLEX: field_package_name]
            [TEXT: label_package_name]
              ATTR: Variant("muted")
              CONTENT: "套餐名称"
            [TEXT: value_package_name]
              CONTENT: "{{record.package_name|}}"
          [FLEX: field_package_type]
            [TEXT: label_package_type]
              ATTR: Variant("muted")
              CONTENT: "套餐类型"
            [BADGE: value_package_type]
              CONTENT: "{{record.package_type|}}"
          [FLEX: field_departure_city_code]
            [TEXT: label_departure_city_code]
              ATTR: Variant("muted")
              CONTENT: "出发城市编码"
            [TEXT: value_departure_city_code]
              CONTENT: "{{record.departure_city_code|}}"
          [FLEX: field_destination_code]
            [TEXT: label_destination_code]
              ATTR: Variant("muted")
              CONTENT: "目的地编码"
            [TEXT: value_destination_code]
              CONTENT: "{{record.destination_code|}}"
          [FLEX: field_start_date]
            [TEXT: label_start_date]
              ATTR: Variant("muted")
              CONTENT: "出行开始日期"
            [TEXT: value_start_date]
              CONTENT: "{{record.start_date|}}"
          [FLEX: field_end_date]
            [TEXT: label_end_date]
              ATTR: Variant("muted")
              CONTENT: "出行结束日期"
            [TEXT: value_end_date]
              CONTENT: "{{record.end_date|}}"
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
          [FLEX: field_inventory_count]
            [TEXT: label_inventory_count]
              ATTR: Variant("muted")
              CONTENT: "可售库存快照"
            [TEXT: value_inventory_count]
              CONTENT: "{{record.inventory_count|}}"
          [FLEX: field_booking_rules]
            [TEXT: label_booking_rules]
              ATTR: Variant("muted")
              CONTENT: "预订规则快照"
            [TEXT: value_booking_rules]
              CONTENT: "{{record.booking_rules|}}"
          [FLEX: field_cancellation_policy]
            [TEXT: label_cancellation_policy]
              ATTR: Variant("muted")
              CONTENT: "取消规则快照"
            [TEXT: value_cancellation_policy]
              CONTENT: "{{record.cancellation_policy|}}"
          [FLEX: field_sale_status]
            [TEXT: label_sale_status]
              ATTR: Variant("muted")
              CONTENT: "sale_status"
            [BADGE: value_sale_status]
              CONTENT: "{{record.sale_status|}}"
      [ELSE]
        [FORM: vacation_offer_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: vacation_offer_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_tenant_id]
              ATTR: Name("tenant_id"), Label("tenant_id"), Placeholder("请输入tenant_id"), Required("true")
            [INPUT: form_host_shop_id]
              ATTR: Name("host_shop_id"), Label("宿主商城 ID，仅用于宿主侧隔离和桥接上下文"), Placeholder("请输入宿主商城 ID，仅用于宿主侧隔离和桥接上下文")
            [INPUT: form_supplier_code]
              ATTR: Name("supplier_code"), Label("供应商编码"), Placeholder("请输入供应商编码"), Required("true")
            [INPUT: form_package_code]
              ATTR: Name("package_code"), Label("套餐编码"), Placeholder("请输入套餐编码"), Required("true")
            [INPUT: form_package_name]
              ATTR: Name("package_name"), Label("套餐名称"), Placeholder("请输入套餐名称"), Required("true")
            [SELECT: form_package_type]
              ATTR: Name("package_type"), Label("套餐类型")
              BIND: Enum("VacationOffer", "package_type")
            [INPUT: form_departure_city_code]
              ATTR: Name("departure_city_code"), Label("出发城市编码"), Placeholder("请输入出发城市编码"), Required("true")
            [INPUT: form_destination_code]
              ATTR: Name("destination_code"), Label("目的地编码"), Placeholder("请输入目的地编码"), Required("true")
            [INPUT: form_start_date]
              ATTR: Name("start_date"), Label("出行开始日期"), Placeholder("请输入出行开始日期"), Required("true")
            [INPUT: form_end_date]
              ATTR: Name("end_date"), Label("出行结束日期"), Placeholder("请输入出行结束日期"), Required("true")
            [INPUT: form_listed_price]
              ATTR: Name("listed_price"), Label("对客展示价快照"), Placeholder("请输入对客展示价快照"), Required("true")
            [INPUT: form_settlement_price]
              ATTR: Name("settlement_price"), Label("结算价快照"), Placeholder("请输入结算价快照")
            [INPUT: form_currency]
              ATTR: Name("currency"), Label("currency"), Placeholder("请输入currency")
            [INPUT: form_inventory_count]
              ATTR: Name("inventory_count"), Label("可售库存快照"), Placeholder("请输入可售库存快照")
            [TEXTAREA: form_booking_rules]
              ATTR: Name("booking_rules"), Label("预订规则快照"), Placeholder("请输入预订规则快照")
            [TEXTAREA: form_cancellation_policy]
              ATTR: Name("cancellation_policy"), Label("取消规则快照"), Placeholder("请输入取消规则快照")
            [SELECT: form_sale_status]
              ATTR: Name("sale_status"), Label("sale_status")
              BIND: Enum("VacationOffer", "sale_status")
          [FLEX: vacation_offer_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: vacation_offer_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: vacation_offer_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
