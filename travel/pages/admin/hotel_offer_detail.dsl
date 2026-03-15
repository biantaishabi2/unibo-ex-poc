[PAGE: hotel_offer_detail]
  ATTR: Title("HotelOffer 详情")

  [BREADCRUMB: hotel_offer_breadcrumb]
    [BREADCRUMB_LIST: hotel_offer_bc_list]
      [BREADCRUMB_ITEM: hotel_offer_bc_list_item]
        [BREADCRUMB_LINK: hotel_offer_bc_link]
          ATTR: Patch("/travel/hotel_offer")
          CONTENT: "HotelOffer 列表"
      [BREADCRUMB_SEPARATOR: hotel_offer_bc_sep]
      [BREADCRUMB_ITEM: hotel_offer_bc_current_item]
        [BREADCRUMB_PAGE: hotel_offer_bc_current]
          CONTENT: "{{record.supplier_code|详情}}"

  [SECTION: hotel_offer_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: hotel_offer_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: hotel_offer_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.supplier_code|}}"
      [BADGE: hotel_offer_status_badge]
        CONTENT: "{{record.sale_status|}}"
    [FLEX: hotel_offer_actions]
      { Gap: 2 }
      [BUTTON: hotel_offer_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"
      [BUTTON: hotel_offer_action_activate]
        ATTR: Variant("secondary"), Click("action_activate")
        CONTENT: "activate"
      [BUTTON: hotel_offer_action_deactivate]
        ATTR: Variant("secondary"), Click("action_deactivate")
        CONTENT: "deactivate"
      [BUTTON: hotel_offer_action_expire]
        ATTR: Variant("secondary"), Click("action_expire")
        CONTENT: "expire"
      [BUTTON: hotel_offer_delete_btn]
        ATTR: Variant("danger"), Click("action_destroy")
        CONTENT: "删除"

  [CARD: hotel_offer_info_card]
    [CARD_HEADER: hotel_offer_info_header]
      [CARD_TITLE: hotel_offer_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: hotel_offer_info_content]
      [IF: !editing]
        [GRID: hotel_offer_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_tenant_id]
            [TEXT: label_tenant_id]
              ATTR: Variant("muted")
              CONTENT: "租户 ID"
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
          [FLEX: field_hotel_code]
            [TEXT: label_hotel_code]
              ATTR: Variant("muted")
              CONTENT: "酒店编码"
            [TEXT: value_hotel_code]
              CONTENT: "{{record.hotel_code|}}"
          [FLEX: field_hotel_name]
            [TEXT: label_hotel_name]
              ATTR: Variant("muted")
              CONTENT: "酒店名称"
            [TEXT: value_hotel_name]
              CONTENT: "{{record.hotel_name|}}"
          [FLEX: field_city_code]
            [TEXT: label_city_code]
              ATTR: Variant("muted")
              CONTENT: "城市编码"
            [TEXT: value_city_code]
              CONTENT: "{{record.city_code|}}"
          [FLEX: field_room_type_code]
            [TEXT: label_room_type_code]
              ATTR: Variant("muted")
              CONTENT: "房型编码"
            [TEXT: value_room_type_code]
              CONTENT: "{{record.room_type_code|}}"
          [FLEX: field_rate_plan_code]
            [TEXT: label_rate_plan_code]
              ATTR: Variant("muted")
              CONTENT: "价计划编码"
            [TEXT: value_rate_plan_code]
              CONTENT: "{{record.rate_plan_code|}}"
          [FLEX: field_checkin_date]
            [TEXT: label_checkin_date]
              ATTR: Variant("muted")
              CONTENT: "入住日期"
            [TEXT: value_checkin_date]
              CONTENT: "{{record.checkin_date|}}"
          [FLEX: field_checkout_date]
            [TEXT: label_checkout_date]
              ATTR: Variant("muted")
              CONTENT: "离店日期"
            [TEXT: value_checkout_date]
              CONTENT: "{{record.checkout_date|}}"
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
              CONTENT: "币种"
            [TEXT: value_currency]
              CONTENT: "{{record.currency|}}"
          [FLEX: field_inventory_count]
            [TEXT: label_inventory_count]
              ATTR: Variant("muted")
              CONTENT: "可售库存快照"
            [TEXT: value_inventory_count]
              CONTENT: "{{record.inventory_count|}}"
          [FLEX: field_cancellation_policy]
            [TEXT: label_cancellation_policy]
              ATTR: Variant("muted")
              CONTENT: "取消规则快照"
            [TEXT: value_cancellation_policy]
              CONTENT: "{{record.cancellation_policy|}}"
          [FLEX: field_guarantee_policy]
            [TEXT: label_guarantee_policy]
              ATTR: Variant("muted")
              CONTENT: "担保规则快照"
            [TEXT: value_guarantee_policy]
              CONTENT: "{{record.guarantee_policy|}}"
          [FLEX: field_sale_status]
            [TEXT: label_sale_status]
              ATTR: Variant("muted")
              CONTENT: "可售状态"
            [BADGE: value_sale_status]
              CONTENT: "{{record.sale_status|}}"
      [ELSE]
        [FORM: hotel_offer_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: hotel_offer_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_tenant_id]
              ATTR: Name("tenant_id"), Label("租户 ID"), Placeholder("请输入租户 ID"), Required("true")
            [INPUT: form_host_shop_id]
              ATTR: Name("host_shop_id"), Label("宿主商城 ID，仅用于宿主侧隔离和桥接上下文"), Placeholder("请输入宿主商城 ID，仅用于宿主侧隔离和桥接上下文")
            [INPUT: form_supplier_code]
              ATTR: Name("supplier_code"), Label("供应商编码"), Placeholder("请输入供应商编码"), Required("true")
            [INPUT: form_hotel_code]
              ATTR: Name("hotel_code"), Label("酒店编码"), Placeholder("请输入酒店编码"), Required("true")
            [INPUT: form_hotel_name]
              ATTR: Name("hotel_name"), Label("酒店名称"), Placeholder("请输入酒店名称"), Required("true")
            [INPUT: form_city_code]
              ATTR: Name("city_code"), Label("城市编码"), Placeholder("请输入城市编码"), Required("true")
            [INPUT: form_room_type_code]
              ATTR: Name("room_type_code"), Label("房型编码"), Placeholder("请输入房型编码"), Required("true")
            [INPUT: form_rate_plan_code]
              ATTR: Name("rate_plan_code"), Label("价计划编码"), Placeholder("请输入价计划编码"), Required("true")
            [INPUT: form_checkin_date]
              ATTR: Name("checkin_date"), Label("入住日期"), Placeholder("请输入入住日期"), Required("true")
            [INPUT: form_checkout_date]
              ATTR: Name("checkout_date"), Label("离店日期"), Placeholder("请输入离店日期"), Required("true")
            [INPUT: form_listed_price]
              ATTR: Name("listed_price"), Label("对客展示价快照"), Placeholder("请输入对客展示价快照"), Required("true")
            [INPUT: form_settlement_price]
              ATTR: Name("settlement_price"), Label("结算价快照"), Placeholder("请输入结算价快照")
            [INPUT: form_currency]
              ATTR: Name("currency"), Label("币种"), Placeholder("请输入币种")
            [INPUT: form_inventory_count]
              ATTR: Name("inventory_count"), Label("可售库存快照"), Placeholder("请输入可售库存快照")
            [TEXTAREA: form_cancellation_policy]
              ATTR: Name("cancellation_policy"), Label("取消规则快照"), Placeholder("请输入取消规则快照")
            [TEXTAREA: form_guarantee_policy]
              ATTR: Name("guarantee_policy"), Label("担保规则快照"), Placeholder("请输入担保规则快照")
            [SELECT: form_sale_status]
              ATTR: Name("sale_status"), Label("可售状态")
          [FLEX: hotel_offer_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: hotel_offer_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: hotel_offer_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
