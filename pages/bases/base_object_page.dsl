[PAGE: base_object]
  ATTR: Title("详情")

  [SECTION: breadcrumb_section]
    [BREADCRUMB: page_breadcrumb]
      [BREADCRUMB_LIST: bc_list]
        [BREADCRUMB_ITEM: bc_list_item]
          [BREADCRUMB_LINK: bc_link]
            CONTENT: "列表"
        [BREADCRUMB_SEPARATOR: bc_sep]
        [BREADCRUMB_ITEM: bc_current_item]
          [BREADCRUMB_PAGE: bc_current]
            CONTENT: "详情"

  [SECTION: detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: title_group]
      { Gap: 3, Align: "Center" }
      [STACK: title_meta]
        BIND: EntityMeta()
      [BADGE: status_badge]
        BIND: StateBadge("status")
    [FLEX: actions_group]
      { Gap: 2 }
      [BUTTON: edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"
      [BUTTON: delete_btn]
        ATTR: Variant("danger"), Click("action_destroy")
        CONTENT: "删除"

  [SECTION: info_section]
    [CARD: info_card]
      [CARD_HEADER: info_header]
        [CARD_TITLE: info_title]
          CONTENT: "基本信息"
      [CARD_CONTENT: info_content]
        [IF: !editing]
          [GRID: info_grid]
            { Columns: 2, Gap: 4 }
            [GRID: detail_fields]
              BIND: Fields("*")
        [ELSE]
          [FORM: edit_form]
            ATTR: Submit("form_submit"), Change("form_change")
            [GRID: form_grid]
              { Columns: 2, Gap: 4 }
              [STACK: form_fields]
                BIND: Form("update")
            [FLEX: form_actions]
              { Justify: "End", Gap: 2 }
              [BUTTON: cancel_btn]
                ATTR: Variant("secondary"), Click("cancel_edit")
                CONTENT: "取消"
              [BUTTON: save_btn]
                ATTR: Variant("primary"), Click("form_submit")
                CONTENT: "保存"
        [/IF]

[SECTION: info_section@tree_split]
  [SPLIT: main_split]
    ATTR: Ratio("1:3")
    [STACK: left_panel]
      [TREE: entity_tree]
        CONTENT: "树结构"
    [STACK: right_panel]
      [CARD: detail_card]
        [CARD_HEADER: tree_detail_header]
          [CARD_TITLE: tree_detail_title]
            CONTENT: "详情"
        [CARD_CONTENT: tree_detail_content]
          [GRID: tree_detail_fields]
            BIND: Fields("*")
      [CARD: relation_card]
        [CARD_HEADER: relation_header]
          [CARD_TITLE: relation_title]
            CONTENT: "关联数据"
        [CARD_CONTENT: relation_content]
          [TABLE: relation_table]
            [TABLE_HEADER: rel_header]
              [TABLE_ROW: rel_header_row]
                [TABLE_HEAD: rel_th_placeholder]
                  CONTENT: "列名"
            [TABLE_BODY: rel_body]
              [TEXT: rel_body_placeholder]
                CONTENT: "数据行"

[SECTION: info_section@nav_split]
  [SPLIT: settings_split]
    ATTR: Ratio("1:3")
    [CARD: nav_card]
      [CARD_CONTENT: nav_content]
        [STACK: nav_menu]
          { Gap: 1 }
          [BUTTON: nav_general]
            ATTR: Variant("ghost"), Click("navigate_general")
            CONTENT: "基本设置"
          [BUTTON: nav_notification]
            ATTR: Variant("ghost"), Click("navigate_notification")
            CONTENT: "通知设置"
          [BUTTON: nav_security]
            ATTR: Variant("ghost"), Click("navigate_security")
            CONTENT: "安全设置"
          [BUTTON: nav_display]
            ATTR: Variant("ghost"), Click("navigate_display")
            CONTENT: "显示设置"
          [BUTTON: nav_advanced]
            ATTR: Variant("ghost"), Click("navigate_advanced")
            CONTENT: "高级设置"
    [STACK: settings_content]
      { Gap: 4 }
      [CARD: general_card]
        [CARD_HEADER: general_header]
          [CARD_TITLE: general_title]
            CONTENT: "基本设置"
        [CARD_CONTENT: general_content]
          [STACK: general_fields]
            { Gap: 3 }
            [INPUT: setting_name]
              ATTR: Name("site_name"), Label("站点名称"), Placeholder("请输入站点名称")
            [INPUT: setting_logo]
              ATTR: Name("logo"), Label("Logo"), Type("file")
            [TEXTAREA: setting_description]
              ATTR: Name("site_description"), Label("站点描述"), Placeholder("请输入站点描述")
      [CARD: notification_card]
        [CARD_HEADER: notification_header]
          [CARD_TITLE: notification_title]
            CONTENT: "通知设置"
        [CARD_CONTENT: notification_content]
          [STACK: notification_fields]
            { Gap: 3 }
            [SELECT: notify_method]
              ATTR: Name("notify_method"), Label("默认通知方式")
              CONTENT: "站内消息:in_app"
              CONTENT: "邮件:email"
              CONTENT: "短信:sms"
            [SELECT: notify_frequency]
              ATTR: Name("notify_frequency"), Label("通知频率")
              CONTENT: "即时:realtime"
              CONTENT: "每日汇总:daily"
              CONTENT: "每周汇总:weekly"
      [CARD: security_card]
        [CARD_HEADER: security_header]
          [CARD_TITLE: security_title]
            CONTENT: "安全设置"
        [CARD_CONTENT: security_content]
          [STACK: security_fields]
            { Gap: 3 }
            [SELECT: session_timeout]
              ATTR: Name("session_timeout"), Label("会话超时时间")
              CONTENT: "30分钟:30"
              CONTENT: "1小时:60"
              CONTENT: "2小时:120"
              CONTENT: "4小时:240"
            [SELECT: password_policy]
              ATTR: Name("password_policy"), Label("密码策略")
              CONTENT: "基本:basic"
              CONTENT: "中等:medium"
              CONTENT: "严格:strict"

[SECTION: detail_header@mobile_profile]
  [FLEX: profile_header]
    { Gap: 3, Align: "Center" }
    [TEXT: profile_title]
      ATTR: Variant("h2"), Weight("bold")
      CONTENT: "{{page_title|个人中心}}"
    [TEXT: profile_desc]
      ATTR: Variant("caption"), Color("muted")
      CONTENT: "{{profile_description|}}"

[SECTION: info_section@mobile_profile]
  [GRID: stats_grid]
    { Columns: 3, Gap: 3 }
    [TEXT: stat_placeholder]
      CONTENT: "统计区域"
  [TABS: record_tabs]
    ATTR: DefaultValue("placeholder")
    [TABS_LIST: record_tab_list]
      [TABS_TRIGGER: trigger_placeholder]
        ATTR: Value("placeholder")
        CONTENT: "记录"
  [STACK: records_list]
    { Gap: 2, Padding: 3 }
    [TEXT: records_placeholder]
      CONTENT: "记录列表区域"
  [CARD: recent_card]
    [CARD_HEADER: recent_header]
      [CARD_TITLE: recent_title]
        CONTENT: "最近动态"
    [CARD_CONTENT: recent_content]
      [TEXT: recent_placeholder]
        CONTENT: "最近动态区域"
