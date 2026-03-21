[PAGE: enterprise_settings]
  META: Entity("TravelPolicy"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("企业设置")

  [SECTION: enterprise_settings_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: enterprise_settings_title]
      ATTR: Variant("title")
      CONTENT: "企业设置"

  [CARD: company_info_card]
    [CARD_HEADER: company_info_header]
      [CARD_TITLE: company_info_title]
        CONTENT: "企业基本信息"
    [CARD_CONTENT: company_info_content]
      [FORM: company_info_form]
        ATTR: Submit("company_info_submit"), Change("form_change")
        [GRID: company_info_grid]
          { Columns: 2, Gap: 4 }
          [INPUT: form_company_name]
            ATTR: Name("company_name"), Label("企业名称"), Placeholder("请输入企业名称"), Required("true")
          [INPUT: form_unified_social_credit_code]
            ATTR: Name("unified_social_credit_code"), Label("统一社会信用代码"), Placeholder("请输入统一社会信用代码"), Required("true")
          [INPUT: form_contact_person]
            ATTR: Name("contact_person"), Label("联系人"), Placeholder("请输入联系人姓名")
          [INPUT: form_contact_phone]
            ATTR: Name("contact_phone"), Label("联系电话"), Placeholder("请输入联系电话")
        [FLEX: company_info_actions]
          { Justify: "End", Gap: 2 }
          [BUTTON: company_info_save_btn]
            ATTR: Variant("primary"), Click("company_info_submit")
            CONTENT: "保存"

  [CARD: approval_mode_card]
    [CARD_HEADER: approval_mode_header]
      [CARD_TITLE: approval_mode_title]
        CONTENT: "审批模式"
    [CARD_CONTENT: approval_mode_content]
      [TEXT: approval_mode_label]
        ATTR: Variant("muted")
        CONTENT: "审批模式"
      [SELECT: approval_mode]
        ATTR: Name("approval_mode"), Label("审批模式"), Change("approval_mode_change")
        CONTENT: "关闭审批:none,自建审批:self,OA集成:oa"
      [IF: approval_mode == "oa"]
        [ALERT: oa_integration_alert]
          ATTR: Variant("info")
          CONTENT: "已选择 OA 集成模式，请前往「OA 集成配置」页面完成对接设置。"
      [/IF]
      [FLEX: approval_mode_actions]
        { Justify: "End", Gap: 2 }
        [BUTTON: approval_mode_save_btn]
          ATTR: Variant("primary"), Click("approval_mode_submit")
          CONTENT: "保存"

  [CARD: travel_settings_card]
    [CARD_HEADER: travel_settings_header]
      [CARD_TITLE: travel_settings_title]
        CONTENT: "差旅默认设置"
    [CARD_CONTENT: travel_settings_content]
      [FORM: travel_settings_form]
        ATTR: Submit("travel_settings_submit"), Change("form_change")
        [GRID: travel_settings_grid]
          { Columns: 2, Gap: 4 }
          [SELECT: form_default_payment_method]
            ATTR: Name("default_payment_method"), Label("默认支付方式")
          [SELECT: form_allow_personal_payment]
            ATTR: Name("allow_personal_payment"), Label("是否允许个人支付")
        [FLEX: travel_settings_actions]
          { Justify: "End", Gap: 2 }
          [BUTTON: travel_settings_save_btn]
            ATTR: Variant("primary"), Click("travel_settings_submit")
            CONTENT: "保存"
