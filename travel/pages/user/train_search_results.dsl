EXTENDS: base_search_results
META: Entity("TrainOffer"), Domain("Travel")

[PAGE: train_search_results]
  ATTR: Title("火车票搜索")

  # 覆写顶部导航
  OVERRIDE: section("header_section")
    [HEADER: train_header]
      ATTR: Back(true), Title("火车票搜索"), Subtitle("{{search.route_label|}}")

  # 覆写日期横滑条 - 显示日期+星期
  OVERRIDE: section("date_slider_section")
    [FLEX: train_date_slider]
      { Gap: 2, PaddingX: 3, PaddingY: 2, OverflowX: "scroll", Background: "surface" }
      [FOR: date_item in search.date_range]
        [BADGE: train_date_badge]
          ATTR: Variant("{{date_item.is_selected|}}"), Click("select_date")
          CONTENT: "{{date_item.date_label|}}"
          [TEXT: train_date_weekday]
            ATTR: Variant("caption")
            CONTENT: "{{date_item.weekday|}}"
      [/FOR]

  # 覆写筛选栏
  OVERRIDE: section("filter_section")
    [FLEX: train_filter_bar]
      { Gap: 2, PaddingX: 3, PaddingY: 2, Wrap: true }
      [SELECT: filter_departure_station]
        ATTR: Label("出发站"), Name("filter.departure_station")
      [SELECT: filter_arrival_station]
        ATTR: Label("到达站"), Name("filter.arrival_station")
      [SELECT: filter_train_type]
        ATTR: Label("车次类型"), Name("filter.train_type")
      [SELECT: filter_train_policy]
        ATTR: Label("差标"), Name("filter.policy_compliant")

  # 覆写超标提示
  OVERRIDE: section("alert_section")
    [IF: policy.exceeded == true]
      [ALERT: train_policy_alert]
        ATTR: Variant("warning"), Title("超标提示")
        CONTENT: "标记超标的车次超出差旅标准，预订需审批"
    [/IF]

  # 覆写卡片列表
  OVERRIDE: section("results_section")
    [STACK: train_results_list]
      { Gap: 3, Padding: 3 }
      [FOR: item in trains.items]
        [CARD: train_card]
          ATTR: Click("navigate"), Params("/travel/train/{{item.id|}}")
          [CARD_HEADER: train_card_header]
            [FLEX: train_header_row]
              { Gap: 2, Align: "Center" }
              [TEXT: train_no]
                ATTR: Variant("body"), Weight("bold")
                CONTENT: "{{item.train_no|}}"
              [BADGE: train_type_badge]
                ATTR: Variant("outline")
                CONTENT: "{{item.train_type_label|}}"
              [IF: item.is_policy_compliant == false]
                [BADGE: train_exceed_badge]
                  ATTR: Variant("destructive")
                  CONTENT: "超标"
              [/IF]
          [CARD_CONTENT: train_card_content]
            [STACK: train_detail_stack]
              { Gap: 2 }
              [FLEX: train_time_row]
                { Justify: "Between", Align: "Center" }
                # 出发信息
                [STACK: train_departure_info]
                  { Gap: 0, Align: "Center" }
                  [TEXT: train_departure_time]
                    ATTR: Variant("h2"), Weight("bold")
                    CONTENT: "{{item.departure_time|}}"
                  [TEXT: train_departure_station]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{item.departure_station_name|}}"
                # 运行信息
                [STACK: train_duration_info]
                  { Gap: 0, Align: "Center" }
                  [TEXT: train_duration]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{item.duration_label|}}"
                  [SEPARATOR: train_sep]
                  [TEXT: train_stop_count]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{item.stop_count_label|}}"
                # 到达信息
                [STACK: train_arrival_info]
                  { Gap: 0, Align: "Center" }
                  [TEXT: train_arrival_time]
                    ATTR: Variant("h2"), Weight("bold")
                    CONTENT: "{{item.arrival_time|}}"
                  [TEXT: train_arrival_station]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{item.arrival_station_name|}}"
          [CARD_FOOTER: train_card_footer]
            # 各席别余票和价格
            [FLEX: seat_options_row]
              { Gap: 2, Wrap: true }
              [FOR: seat in item.seat_options]
                [STACK: seat_option]
                  { Gap: 0, Align: "Center" }
                  [TEXT: seat_class_name]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{seat.seat_class_name|}}"
                  [TEXT: seat_price]
                    ATTR: Variant("body"), Color("primary"), Weight("bold")
                    CONTENT: "{{seat.price|}}"
                  [TEXT: seat_tickets]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{seat.tickets_label|}}"
              [/FOR]
      [/FOR]

  # 覆写空状态
  OVERRIDE: section("empty_section")
    [IF: trains.total_count == 0]
      [EMPTY_STATE: no_trains]
        ATTR: Title("未找到车次"), Description("请调整搜索条件后重试"), Icon("train")
    [/IF]

  # 覆写底部排序栏
  OVERRIDE: section("sort_bar_section")
    [CONTROL_BAR: train_sort_bar]
      ATTR: Position("sticky_bottom")
      [FLEX: train_sort_buttons]
        { Gap: 3, Justify: "SpaceAround", Width: "full" }
        [BUTTON: sort_by_duration]
          ATTR: Variant("ghost"), Icon("arrow-up-down"), Click("sort")
          CONTENT: "耗时"
        [BUTTON: sort_by_train_departure]
          ATTR: Variant("ghost"), Icon("arrow-up-down"), Click("sort")
          CONTENT: "出发时间"
        [BUTTON: sort_by_train_price]
          ATTR: Variant("ghost"), Icon("arrow-up-down"), Click("sort")
          CONTENT: "价格"
