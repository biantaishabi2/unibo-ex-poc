[PAGE: base_overview]
  ATTR: Title("概览面板")
  [SECTION: kpi_cards]
    [GRID: kpi_grid]
      BIND: Calculations()
      { Columns: 4, Gap: 4 }
  [SECTION: charts]
    [GRID: chart_grid]
      { Columns: 2, Gap: 4 }
      [CARD: chart_card_1]
        [CARD_HEADER: chart_1_header]
          [CARD_TITLE: chart_1_title]
            CONTENT: "{{chart_1_title|趋势图}}"
        [CARD_CONTENT: chart_1_content]
          [TEXT: chart_1_placeholder]
            CONTENT: "图表区域"
      [CARD: chart_card_2]
        [CARD_HEADER: chart_2_header]
          [CARD_TITLE: chart_2_title]
            CONTENT: "{{chart_2_title|分布图}}"
        [CARD_CONTENT: chart_2_content]
          [TEXT: chart_2_placeholder]
            CONTENT: "图表区域"
  [SECTION: activity_feed]
    [GRID: bottom_grid]
      { Columns: 2, Gap: 4 }
      [CARD: feed_card]
        [CARD_HEADER: feed_header]
          [CARD_TITLE: feed_title]
            CONTENT: "最新动态"
        [CARD_CONTENT: feed_content]
          [STACK: feed_list]
            BIND: EventLog()
            { Gap: 2 }
      [CARD: quick_actions_card]
        [CARD_HEADER: quick_actions_header]
          [CARD_TITLE: quick_actions_title]
            CONTENT: "快捷操作"
        [CARD_CONTENT: quick_actions_content]
          [GRID: action_grid]
            { Columns: 2, Gap: 2 }
            [BUTTON: quick_action_1]
              ATTR: Variant("secondary"), Click("quick_action_1")
              CONTENT: "{{action_1_label|操作一}}"
            [BUTTON: quick_action_2]
              ATTR: Variant("secondary"), Click("quick_action_2")
              CONTENT: "{{action_2_label|操作二}}"
            [BUTTON: quick_action_3]
              ATTR: Variant("secondary"), Click("quick_action_3")
              CONTENT: "{{action_3_label|操作三}}"
            [BUTTON: quick_action_4]
              ATTR: Variant("secondary"), Click("quick_action_4")
              CONTENT: "{{action_4_label|操作四}}"
  [SECTION: kpi_cards@portal]
    [CARD: hero_card]
      { Background: "primary", Padding: 6 }
      [CARD_CONTENT: hero_content]
        [STACK: hero_info]
          { Align: "Center", Gap: 3 }
          [TEXT: hero_title]
            ATTR: Variant("h1"), Weight("bold"), Color("white")
            CONTENT: "{{hero_title|欢迎使用}}"
          [TEXT: hero_subtitle]
            ATTR: Variant("body"), Color("white")
            CONTENT: "{{hero_subtitle|便捷管理，高效协作}}"
          [BUTTON: hero_action]
            ATTR: Variant("secondary"), Click("hero_action")
            CONTENT: "{{hero_action_label|立即开始}}"
  [SECTION: charts@portal]
    [GRID: shortcuts]
      { Columns: 4, Gap: 4 }
      [CARD: shortcut_1]
        [CARD_CONTENT: shortcut_1_content]
          [STACK: shortcut_1_info]
            { Align: "Center", Gap: 2 }
            [ICON: shortcut_1_icon]
              ATTR: Name("{{shortcut_1_icon|file}}"), Size("lg")
            [TEXT: shortcut_1_label]
              ATTR: Weight("bold")
              CONTENT: "{{shortcut_1_label|功能一}}"
            [TEXT: shortcut_1_desc]
              ATTR: Variant("muted")
              CONTENT: "{{shortcut_1_desc|}}"
      [CARD: shortcut_2]
        [CARD_CONTENT: shortcut_2_content]
          [STACK: shortcut_2_info]
            { Align: "Center", Gap: 2 }
            [ICON: shortcut_2_icon]
              ATTR: Name("{{shortcut_2_icon|settings}}"), Size("lg")
            [TEXT: shortcut_2_label]
              ATTR: Weight("bold")
              CONTENT: "{{shortcut_2_label|功能二}}"
            [TEXT: shortcut_2_desc]
              ATTR: Variant("muted")
              CONTENT: "{{shortcut_2_desc|}}"
      [CARD: shortcut_3]
        [CARD_CONTENT: shortcut_3_content]
          [STACK: shortcut_3_info]
            { Align: "Center", Gap: 2 }
            [ICON: shortcut_3_icon]
              ATTR: Name("{{shortcut_3_icon|bell}}"), Size("lg")
            [TEXT: shortcut_3_label]
              ATTR: Weight("bold")
              CONTENT: "{{shortcut_3_label|功能三}}"
            [TEXT: shortcut_3_desc]
              ATTR: Variant("muted")
              CONTENT: "{{shortcut_3_desc|}}"
      [CARD: shortcut_4]
        [CARD_CONTENT: shortcut_4_content]
          [STACK: shortcut_4_info]
            { Align: "Center", Gap: 2 }
            [ICON: shortcut_4_icon]
              ATTR: Name("{{shortcut_4_icon|user}}"), Size("lg")
            [TEXT: shortcut_4_label]
              ATTR: Weight("bold")
              CONTENT: "{{shortcut_4_label|功能四}}"
            [TEXT: shortcut_4_desc]
              ATTR: Variant("muted")
              CONTENT: "{{shortcut_4_desc|}}"
    [CARD: announcement_card]
      [CARD_HEADER: announcement_header]
        [FLEX: announcement_title_bar]
          { Justify: "Between", Align: "Center" }
          [CARD_TITLE: announcement_title]
            CONTENT: "通知公告"
          [BUTTON: announcement_more]
            ATTR: Variant("link"), Click("navigate_announcements")
            CONTENT: "查看更多"
      [CARD_CONTENT: announcement_content]
        [STACK: announcement_list]
          { Gap: 3 }
          [FOR: ann in announcements]
            [FLEX: announcement_item]
              { Justify: "Between", Align: "Center" }
              [STACK: ann_info]
                { Gap: 0 }
                [TEXT: ann_title]
                  ATTR: Weight("bold")
                  CONTENT: "{{ann.title|}}"
                [TEXT: ann_summary]
                  ATTR: Variant("muted")
                  CONTENT: "{{ann.summary|}}"
              [TEXT: ann_date]
                ATTR: Variant("caption")
                CONTENT: "{{ann.publish_at|}}"
          [/FOR]
  [SECTION: activity_feed@portal]
    [GRID: summary_grid]
      { Columns: 3, Gap: 4 }
      [CARD: pending_card]
        [CARD_CONTENT: pending_content]
          [STACK: pending_info]
            { Align: "Center", Gap: 1 }
            [TEXT: pending_value]
              ATTR: Variant("h2"), Weight("bold")
              CONTENT: "{{pending_count|0}}"
            [TEXT: pending_label]
              ATTR: Variant("muted")
              CONTENT: "待办事项"
      [CARD: message_card]
        [CARD_CONTENT: message_content]
          [STACK: message_info]
            { Align: "Center", Gap: 1 }
            [TEXT: message_value]
              ATTR: Variant("h2"), Weight("bold")
              CONTENT: "{{message_count|0}}"
            [TEXT: message_label]
              ATTR: Variant("muted")
              CONTENT: "未读消息"
      [CARD: schedule_card]
        [CARD_CONTENT: schedule_content]
          [STACK: schedule_info]
            { Align: "Center", Gap: 1 }
            [TEXT: schedule_value]
              ATTR: Variant("h2"), Weight("bold")
              CONTENT: "{{schedule_count|0}}"
            [TEXT: schedule_label]
              ATTR: Variant("muted")
              CONTENT: "今日日程"
