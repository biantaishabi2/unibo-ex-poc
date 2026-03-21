[PAGE: travel_policy_detail]
  META: Entity("TravelPolicy"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("TravelPolicy 详情")

  [BREADCRUMB: travel_policy_breadcrumb]
    [BREADCRUMB_LIST: travel_policy_bc_list]
      [BREADCRUMB_ITEM: travel_policy_bc_list_item]
        [BREADCRUMB_LINK: travel_policy_bc_link]
          ATTR: Patch("/travel/travel_policy")
          CONTENT: "TravelPolicy 列表"
      [BREADCRUMB_SEPARATOR: travel_policy_bc_sep]
      [BREADCRUMB_ITEM: travel_policy_bc_current_item]
        [BREADCRUMB_PAGE: travel_policy_bc_current]
          CONTENT: "{{record.policy_name|详情}}"

  [SECTION: travel_policy_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: travel_policy_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: travel_policy_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.policy_name|}}"
      [BADGE: travel_policy_product_type_badge]
        CONTENT: "{{record.product_type|}}"
    [FLEX: travel_policy_actions]
      { Gap: 2 }
      [BUTTON: travel_policy_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"

  [CARD: travel_policy_info_card]
    [CARD_HEADER: travel_policy_info_header]
      [CARD_TITLE: travel_policy_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: travel_policy_info_content]
      [IF: !editing]
        [GRID: travel_policy_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_policy_name]
            [TEXT: label_policy_name]
              ATTR: Variant("muted")
              CONTENT: "政策名称"
            [TEXT: value_policy_name]
              CONTENT: "{{record.policy_name|}}"
          [FLEX: field_product_type]
            [TEXT: label_product_type]
              ATTR: Variant("muted")
              CONTENT: "适用商品类型"
            [BADGE: value_product_type]
              CONTENT: "{{record.product_type|}}"
          [FLEX: field_employee_level]
            [TEXT: label_employee_level]
              ATTR: Variant("muted")
              CONTENT: "职级标识"
            [TEXT: value_employee_level]
              CONTENT: "{{record.employee_level|}}"
          [FLEX: field_city_tier]
            [TEXT: label_city_tier]
              ATTR: Variant("muted")
              CONTENT: "城市等级"
            [TEXT: value_city_tier]
              CONTENT: "{{record.city_tier|}}"
          [FLEX: field_season]
            [TEXT: label_season]
              ATTR: Variant("muted")
              CONTENT: "淡旺季标识"
            [TEXT: value_season]
              CONTENT: "{{record.season|}}"
          [FLEX: field_max_amount]
            [TEXT: label_max_amount]
              ATTR: Variant("muted")
              CONTENT: "金额上限"
            [TEXT: value_max_amount]
              CONTENT: "{{record.max_amount|}}"
          [FLEX: field_cabin_class_limit]
            [TEXT: label_cabin_class_limit]
              ATTR: Variant("muted")
              CONTENT: "舱位限制"
            [TEXT: value_cabin_class_limit]
              CONTENT: "{{record.cabin_class_limit|}}"
          [FLEX: field_hotel_star_limit]
            [TEXT: label_hotel_star_limit]
              ATTR: Variant("muted")
              CONTENT: "酒店星级限制"
            [TEXT: value_hotel_star_limit]
              CONTENT: "{{record.hotel_star_limit|}}"
          [FLEX: field_exceed_strategy]
            [TEXT: label_exceed_strategy]
              ATTR: Variant("muted")
              CONTENT: "超标处理策略"
            [BADGE: value_exceed_strategy]
              CONTENT: "{{record.exceed_strategy|}}"
          [FLEX: field_personal_pay_ratio]
            [TEXT: label_personal_pay_ratio]
              ATTR: Variant("muted")
              CONTENT: "个人支付比例"
            [TEXT: value_personal_pay_ratio]
              CONTENT: "{{record.personal_pay_ratio|}}"
          [FLEX: field_is_active]
            [TEXT: label_is_active]
              ATTR: Variant("muted")
              CONTENT: "是否启用"
            [BADGE: value_is_active]
              CONTENT: "{{record.is_active|}}"
          [FLEX: field_enterprise_id]
            [TEXT: label_enterprise_id]
              ATTR: Variant("muted")
              CONTENT: "企业标识"
            [TEXT: value_enterprise_id]
              CONTENT: "{{record.enterprise_id|}}"
      [ELSE]
        [FORM: travel_policy_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: travel_policy_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_policy_name]
              ATTR: Name("policy_name"), Label("政策名称"), Placeholder("请输入政策名称"), Required("true")
            [INPUT: form_season]
              ATTR: Name("season"), Label("淡旺季标识"), Placeholder("请输入淡旺季标识")
            [INPUT: form_max_amount]
              ATTR: Name("max_amount"), Label("金额上限"), Placeholder("请输入金额上限")
            [INPUT: form_cabin_class_limit]
              ATTR: Name("cabin_class_limit"), Label("舱位限制"), Placeholder("请输入舱位限制")
            [INPUT: form_hotel_star_limit]
              ATTR: Name("hotel_star_limit"), Label("酒店星级限制"), Placeholder("请输入酒店星级限制")
            [SELECT: form_exceed_strategy]
              ATTR: Name("exceed_strategy"), Label("超标处理策略"), Required("true")
            [INPUT: form_personal_pay_ratio]
              ATTR: Name("personal_pay_ratio"), Label("个人支付比例"), Placeholder("请输入个人支付比例")
            [SWITCH: form_is_active]
              ATTR: Name("is_active"), Label("是否启用")
          [FLEX: travel_policy_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: travel_policy_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: travel_policy_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
