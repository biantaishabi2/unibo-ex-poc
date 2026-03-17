# 个人中心页
# 展示用户头像/信息、快捷入口、出差统计、设置入口

[PAGE: personal_center]
  ATTR: Title("个人中心")

  [HEADER: personal_center_header]
    ATTR: Title("个人中心")

  # 个人资料区
  [SECTION: profile_section]
    [CARD: profile_card]
      [CARD_CONTENT: profile_card_content]
        [FLEX: profile_flex]
          { Gap: 4, Align: "Center", PaddingY: 4 }
          [AVATAR: user_avatar]
            ATTR: Src("{{user.avatar_url|}}"), Fallback("{{user.name_initial|}}"), Size("xl")
          [STACK: user_info_stack]
            { Gap: 1 }
            [TEXT: user_name]
              ATTR: Variant("h3"), Weight("bold")
              CONTENT: "{{user.display_name|}}"
            [FLEX: user_dept_row]
              { Gap: 2, Align: "Center" }
              [TEXT: user_department]
                ATTR: Variant("body"), Color("muted")
                CONTENT: "{{user.department_name|}}"
              [BADGE: user_level_badge]
                ATTR: Variant("secondary")
                CONTENT: "{{user.job_level_label|}}"
            [TEXT: user_email]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{user.email|}}"

  # 快捷入口
  [SECTION: quick_links]
    [CARD: quick_links_card]
      [CARD_CONTENT: quick_links_content]
        [FLEX: quick_links_grid]
          { Gap: 2, Justify: "SpaceAround", PaddingY: 2, Wrap: true }
          [STACK: link_orders]
            ATTR: Click("navigate:/travel/orders")
            { Gap: 1, Align: "Center" }
            [ICON: orders_icon]
              ATTR: Name("file-text"), Size("lg"), Color("primary")
            [TEXT: orders_label]
              ATTR: Variant("caption")
              CONTENT: "我的订单"
          [STACK: link_approvals]
            ATTR: Click("navigate:/travel/my-approvals")
            { Gap: 1, Align: "Center" }
            [ICON: approvals_icon]
              ATTR: Name("check-square"), Size("lg"), Color("primary")
            [TEXT: approvals_label]
              ATTR: Variant("caption")
              CONTENT: "我的审批"
          [STACK: link_trip_request]
            ATTR: Click("navigate:/travel/request/new")
            { Gap: 1, Align: "Center" }
            [ICON: trip_request_icon]
              ATTR: Name("map-pin"), Size("lg"), Color("primary")
            [TEXT: trip_request_label]
              ATTR: Variant("caption")
              CONTENT: "出差申请"
          [STACK: link_expense]
            ATTR: Click("navigate:/travel/expense")
            { Gap: 1, Align: "Center" }
            [ICON: expense_icon]
              ATTR: Name("receipt"), Size("lg"), Color("primary")
            [TEXT: expense_label]
              ATTR: Variant("caption")
              CONTENT: "差旅报销"

  # 出差统计
  [SECTION: stats_section]
    [CARD: stats_card]
      [CARD_HEADER: stats_header]
        [FLEX: stats_header_row]
          { Justify: "Between", Align: "Center" }
          [TEXT: stats_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "本月出差概况"
          [TEXT: stats_period]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "{{stats.period_label|}}"
      [CARD_CONTENT: stats_content]
        [FLEX: stats_row]
          { Justify: "SpaceAround", PaddingY: 2 }
          [STACK: stats_trip_count]
            { Gap: 1, Align: "Center" }
            [TEXT: trip_count_value]
              ATTR: Variant("h2"), Color("primary"), Weight("bold")
              CONTENT: "{{stats.trip_count|0}}"
            [TEXT: trip_count_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "出差次数"
          [SEPARATOR: stats_sep1]
            ATTR: Orientation("vertical")
          [STACK: stats_travel_cost]
            { Gap: 1, Align: "Center" }
            [TEXT: travel_cost_value]
              ATTR: Variant("h2"), Color("primary"), Weight("bold")
              CONTENT: "¥{{stats.total_cost|0}}"
            [TEXT: travel_cost_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "差旅费用"
          [SEPARATOR: stats_sep2]
            ATTR: Orientation("vertical")
          [STACK: stats_pending_approvals]
            { Gap: 1, Align: "Center" }
            [FLEX: pending_count_row]
              { Gap: 1, Align: "Center" }
              [TEXT: pending_count_value]
                ATTR: Variant("h2"), Color("primary"), Weight("bold")
                CONTENT: "{{stats.pending_count|0}}"
            [TEXT: pending_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "待审批"

  # 设置入口列表
  [SECTION: settings_section]
    [CARD: settings_card]
      [CARD_CONTENT: settings_content]
        [STACK: settings_list]
          { Gap: 0 }
          [FLEX: setting_common_travelers]
            ATTR: Click("navigate:/travel/traveler-management")
            { Justify: "Between", Align: "Center", PaddingY: 3 }
            [FLEX: setting_item_left]
              { Gap: 3, Align: "Center" }
              [ICON: travelers_icon]
                ATTR: Name("users"), Size("sm"), Color("muted")
              [TEXT: travelers_label]
                ATTR: Variant("body")
                CONTENT: "常用出行人"
            [ICON: chevron_right_1]
              ATTR: Name("chevron-right"), Size("sm"), Color("muted")
          [SEPARATOR: sep_travelers]
          [FLEX: setting_invoice_header]
            ATTR: Click("navigate:/travel/invoice-headers")
            { Justify: "Between", Align: "Center", PaddingY: 3 }
            [FLEX: setting_invoice_left]
              { Gap: 3, Align: "Center" }
              [ICON: invoice_icon]
                ATTR: Name("file-invoice"), Size("sm"), Color("muted")
              [TEXT: invoice_label]
                ATTR: Variant("body")
                CONTENT: "发票抬头"
            [ICON: chevron_right_2]
              ATTR: Name("chevron-right"), Size("sm"), Color("muted")
          [SEPARATOR: sep_invoice]
          [FLEX: setting_notifications]
            ATTR: Click("navigate:/travel/notifications")
            { Justify: "Between", Align: "Center", PaddingY: 3 }
            [FLEX: setting_notif_left]
              { Gap: 3, Align: "Center" }
              [ICON: notification_icon]
                ATTR: Name("bell"), Size("sm"), Color("muted")
              [TEXT: notification_label]
                ATTR: Variant("body")
                CONTENT: "消息通知"
            [ICON: chevron_right_3]
              ATTR: Name("chevron-right"), Size("sm"), Color("muted")
          [SEPARATOR: sep_notifications]
          [FLEX: setting_policy]
            ATTR: Click("navigate:/travel/policy")
            { Justify: "Between", Align: "Center", PaddingY: 3 }
            [FLEX: setting_policy_left]
              { Gap: 3, Align: "Center" }
              [ICON: policy_icon]
                ATTR: Name("shield"), Size("sm"), Color("muted")
              [TEXT: policy_label]
                ATTR: Variant("body")
                CONTENT: "差旅政策"
            [ICON: chevron_right_4]
              ATTR: Name("chevron-right"), Size("sm"), Color("muted")
