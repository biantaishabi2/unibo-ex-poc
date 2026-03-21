[PAGE: oa_integration_config]
  META: Entity("TravelOrder"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("OA 集成配置")

  [SECTION: oa_integration_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: oa_integration_title]
      ATTR: Variant("title")
      CONTENT: "OA 集成配置"

  [CARD: provider_card]
    [CARD_HEADER: provider_card_header]
      [CARD_TITLE: provider_card_title]
        CONTENT: "OA 服务商选择"
    [CARD_CONTENT: provider_card_content]
      [SELECT: oa_provider]
        ATTR: Name("oa_provider"), Label("OA 服务商"), Change("oa_provider_change")

  [CARD: credentials_card]
    [CARD_HEADER: credentials_card_header]
      [CARD_TITLE: credentials_card_title]
        CONTENT: "接入凭证配置"
    [CARD_CONTENT: credentials_card_content]
      [FORM: oa_form]
        ATTR: Submit("oa_form_submit"), Change("form_change")
        [GRID: oa_form_grid]
          { Columns: 2, Gap: 4 }
          [INPUT: form_app_key]
            ATTR: Name("app_key"), Label("AppKey"), Placeholder("请输入 AppKey"), Required("true")
          [INPUT: form_app_secret]
            ATTR: Name("app_secret"), Label("AppSecret"), Placeholder("请输入 AppSecret"), Required("true")
          [INPUT: form_callback_url]
            ATTR: Name("callback_url"), Label("回调地址"), Placeholder("请输入回调地址")
          [SELECT: form_sync_frequency]
            ATTR: Name("sync_frequency"), Label("同步频率")
        [FLEX: oa_form_actions]
          { Justify: "End", Gap: 2 }
          [BUTTON: oa_form_save_btn]
            ATTR: Variant("primary"), Click("oa_form_submit")
            CONTENT: "保存配置"

  [CARD: sync_status_card]
    [CARD_HEADER: sync_status_card_header]
      [CARD_TITLE: sync_status_card_title]
        CONTENT: "同步状态"
    [CARD_CONTENT: sync_status_card_content]
      [GRID: sync_status_grid]
        { Columns: 2, Gap: 4 }
        [FLEX: field_last_sync_time]
          [TEXT: label_last_sync_time]
            ATTR: Variant("muted")
            CONTENT: "最近同步时间"
          [TEXT: value_last_sync_time]
            CONTENT: "{{sync_status.last_sync_time|}}"
        [FLEX: field_sync_status]
          [TEXT: label_sync_status]
            ATTR: Variant("muted")
            CONTENT: "同步状态"
          [BADGE: value_sync_status]
            CONTENT: "{{sync_status.status|}}"
      [FLEX: sync_actions]
        { Justify: "End", Gap: 2 }
        [BUTTON: manual_sync_btn]
          ATTR: Variant("secondary"), Click("trigger_manual_sync")
          CONTENT: "手动同步"
