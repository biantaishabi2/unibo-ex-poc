EXTENDS: base_search_results
META: Entity("FlightOffer"), Domain("Travel"), FilterMode("search_only")

[PAGE: flight_search_results]
  ATTR: Title("机票搜索")

  # 覆写顶部导航
  OVERRIDE: header_section
    [HEADER: flight_header]
      ATTR: Back(true), Title("机票搜索"), Subtitle("{{search.route_label|}}")

  # 覆写日期横滑条 - 显示日期+价格
  OVERRIDE: date_slider_section
    [FLEX: flight_date_slider]
      { Gap: 2, PaddingX: 3, PaddingY: 2, OverflowX: "scroll", Background: "surface" }
      [FOR: date_item in search.date_range]
        [BADGE: flight_date_badge]
          ATTR: Variant("{{date_item.is_selected|}}"), Click("select_date")
          CONTENT: "{{date_item.date_label|}}"
          [TEXT: flight_date_price]
            ATTR: Variant("caption")
            CONTENT: "{{date_item.price_label|}}"
      [/FOR]

  # 覆写筛选栏
  OVERRIDE: filter_section
    [FLEX: flight_filter_bar]
      { Gap: 2, PaddingX: 3, PaddingY: 2, Wrap: true }
      [SELECT: filter_departure_airport]
        ATTR: Label("出发机场"), Name("filter.departure_airport")
      [SELECT: filter_arrival_airport]
        ATTR: Label("到达机场"), Name("filter.arrival_airport")
      [SELECT: filter_airline]
        ATTR: Label("航空公司"), Name("filter.airline")
      [SELECT: filter_policy]
        ATTR: Label("差标"), Name("filter.policy_compliant")
      [SELECT: filter_cabin]
        ATTR: Label("舱位"), Name("filter.cabin_class")

  # 覆写超标提示
  OVERRIDE: alert_section
    [IF: policy.exceeded == true]
      [ALERT: flight_policy_alert]
        ATTR: Variant("warning"), Title("超标提示")
        CONTENT: "标记超标的航班超出差旅标准，预订需审批"
    [/IF]

  # 覆写卡片列表
  OVERRIDE: results_section
    [STACK: flight_results_list]
      { Gap: 3, Padding: 3 }
      [FOR: item in flights.items]
        [CARD: flight_card]
          ATTR: Click("navigate"), Params("/travel/flight/{{item.id|}}")
          [CARD_HEADER: flight_card_header]
            [FLEX: flight_header_row]
              { Gap: 2, Align: "Center" }
              [AVATAR: airline_avatar]
                ATTR: Src("{{item.airline_ref.logo|}}"), Fallback("{{item.airline_ref.code|}}"), Size("sm")
              [TEXT: airline_name]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{item.airline_ref.name|}}"
              [TEXT: flight_no]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{item.flight_no|}}"
              [IF: item.is_policy_compliant == false]
                [BADGE: flight_exceed_badge]
                  ATTR: Variant("destructive")
                  CONTENT: "超标"
              [/IF]
          [CARD_CONTENT: flight_card_content]
            [FLEX: flight_time_row]
              { Justify: "Between", Align: "Center" }
              # 出发信息
              [STACK: departure_info]
                { Gap: 0, Align: "Center" }
                [TEXT: departure_time]
                  ATTR: Variant("h2"), Weight("bold")
                  CONTENT: "{{item.departure_time|}}"
                [TEXT: departure_city]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.departure_airport_ref.city_name|}}"
                [TEXT: departure_code]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.departure_airport_code|}}"
              # 飞行信息
              [STACK: flight_duration_info]
                { Gap: 0, Align: "Center" }
                [TEXT: flight_duration]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.duration_label|}}"
                [SEPARATOR: flight_sep]
                [TEXT: flight_stop]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.stop_label|}}"
              # 到达信息
              [STACK: arrival_info]
                { Gap: 0, Align: "Center" }
                [TEXT: arrival_time]
                  ATTR: Variant("h2"), Weight("bold")
                  CONTENT: "{{item.arrival_time|}}"
                [TEXT: arrival_city]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.arrival_airport_ref.city_name|}}"
                [TEXT: arrival_code]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.arrival_airport_code|}}"
          [CARD_FOOTER: flight_card_footer]
            [FLEX: flight_footer_row]
              { Justify: "Between", Align: "Center" }
              [FLEX: flight_tags]
                { Gap: 1, Wrap: true }
                [BADGE: cabin_class_badge]
                  ATTR: Variant("outline")
                  CONTENT: "{{item.cabin_class_ref.name|}}"
                [BADGE: aircraft_badge]
                  ATTR: Variant("outline")
                  CONTENT: "{{item.aircraft_type|}}"
                [IF: item.discount_label != null]
                  [BADGE: discount_badge]
                    ATTR: Variant("success")
                    CONTENT: "{{item.discount_label|}}"
                [/IF]
              [FLEX: flight_price]
                { Gap: 1, Align: "Baseline" }
                [TEXT: flight_currency]
                  ATTR: Variant("caption")
                  CONTENT: "{{item.currency|}}"
                [TEXT: flight_listed_price]
                  ATTR: Variant("h3"), Color("primary")
                  CONTENT: "{{item.listed_price|}}"
      [/FOR]

  # 覆写空状态
  OVERRIDE: empty_section
    [IF: flights.total_count == 0]
      [EMPTY_STATE: no_flights]
        ATTR: Title("未找到航班"), Description("请调整搜索条件后重试"), Icon("plane")
    [/IF]

  # 覆写底部排序栏
  OVERRIDE: sort_bar_section
    [CONTROL_BAR: flight_sort_bar]
      ATTR: Position("sticky_bottom")
      [FLEX: flight_sort_buttons]
        { Gap: 3, Justify: "SpaceAround", Width: "full" }
        [BUTTON: sort_by_price]
          ATTR: Variant("ghost"), Icon("arrow-up-down"), Click("sort")
          CONTENT: "价格"
        [BUTTON: sort_by_departure]
          ATTR: Variant("ghost"), Icon("arrow-up-down"), Click("sort")
          CONTENT: "出发时间"
        [BUTTON: sort_by_recommended]
          ATTR: Variant("ghost"), Icon("star"), Click("sort")
          CONTENT: "推荐"
