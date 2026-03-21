# 改签航班/车次选择页
# 基于 base_search_results，覆写筛选栏（出发/到达城市+日期选择）和结果卡片（展示原航班 vs 新航班对比）

[PAGE: change_flight_search]
  ATTR: Title("改签选择")
  META: Entity("FlightOffer"), Domain("Travel")
  BIND: Fields("*")
  EXTENDS: base_search_results

  # 覆写顶部导航
  OVERRIDE: header_section
    [HEADER: change_search_header]
      ATTR: Back(true), Title("改签选择"), Subtitle("原：{{original_order.summary|}}")

  # 覆写日期横滑条
  OVERRIDE: date_slider_section
    [FLEX: change_date_slider]
      { Gap: 2, PaddingX: 3, PaddingY: 2, OverflowX: "scroll", Background: "surface" }
      [FOR: date_item in search.date_range]
        [BADGE: change_date_badge]
          ATTR: Variant("{{date_item.is_selected|}}"), Click("select_date")
          CONTENT: "{{date_item.date_label|}}"
          [TEXT: change_date_price]
            ATTR: Variant("caption")
            CONTENT: "{{date_item.price_label|}}"
      [/FOR]

  # 覆写筛选栏：出发/到达城市 + 日期
  OVERRIDE: filter_section
    [FLEX: change_filter_bar]
      { Gap: 2, PaddingX: 3, PaddingY: 2, Wrap: true }
      [SELECT: change_departure_city]
        ATTR: Label("出发城市"), Name("filter.departure_city"), Placeholder("请选择出发城市")
      [SELECT: change_arrival_city]
        ATTR: Label("到达城市"), Name("filter.arrival_city"), Placeholder("请选择到达城市")
      [DATE_PICKER: change_date_picker]
        ATTR: Label("出发日期"), Name("filter.departure_date"), Placeholder("选择日期")
      [SELECT: change_type]
        ATTR: Label("类型"), Name("filter.transport_type")
        [OPTION: opt_flight] CONTENT: "机票"
        [OPTION: opt_train] CONTENT: "火车"
      [SELECT: change_policy_filter]
        ATTR: Label("差标"), Name("filter.policy_compliant")
        [OPTION: opt_all] CONTENT: "全部"
        [OPTION: opt_compliant] CONTENT: "符合差标"

  # 超标提示
  OVERRIDE: alert_section
    [IF: policy.exceeded == true]
      [ALERT: change_policy_alert]
        ATTR: Variant("warning"), Title("超标提示")
        CONTENT: "标记超标的选项超出差旅标准，改签后需审批"
    [/IF]

  # 覆写卡片列表：展示原航班 vs 新航班对比
  OVERRIDE: results_section
    [STACK: change_results_list]
      { Gap: 3, Padding: 3 }
      [FOR: item in results.items]
        [CARD: change_result_card]
          ATTR: Click("navigate"), Params("/travel/change/confirm/{{item.id|}}")
          [CARD_HEADER: change_card_header]
            [FLEX: change_header_row]
              { Gap: 2, Align: "Center", Justify: "Between" }
              [FLEX: transport_info_row]
                { Gap: 2, Align: "Center" }
                [AVATAR: transport_avatar]
                  ATTR: Src("{{item.carrier_logo|}}"), Fallback("{{item.carrier_code|}}"), Size("sm")
                [TEXT: transport_no]
                  ATTR: Variant("body"), Weight("bold")
                  CONTENT: "{{item.transport_no|}}"
              [IF: item.is_policy_compliant == false]
                [BADGE: change_exceed_badge]
                  ATTR: Variant("destructive")
                  CONTENT: "超标"
              [/IF]
          [CARD_CONTENT: change_card_content]
            # 原航班信息（灰色）
            [FLEX: original_row]
              { Gap: 2, Align: "Center", PaddingY: 1 }
              [BADGE: original_label_badge]
                ATTR: Variant("secondary")
                CONTENT: "原"
              [FLEX: original_time_row]
                { Gap: 2, Align: "Center" }
                [TEXT: original_dep_time]
                  ATTR: Variant("caption"), Color("muted"), Style("line-through")
                  CONTENT: "{{item.original.departure_time|}}"
                [TEXT: original_route_sep]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "→"
                [TEXT: original_arr_time]
                  ATTR: Variant("caption"), Color("muted"), Style("line-through")
                  CONTENT: "{{item.original.arrival_time|}}"
                [TEXT: original_price]
                  ATTR: Variant("caption"), Color("muted"), Style("line-through")
                  CONTENT: "¥{{item.original.price|}}"
            # 新航班信息
            [FLEX: new_row]
              { Gap: 2, Align: "Center", PaddingY: 1 }
              [BADGE: new_label_badge]
                ATTR: Variant("primary")
                CONTENT: "新"
              [FLEX: new_time_row]
                { Justify: "Between", Align: "Center", Gap: 2 }
                [STACK: new_departure_info]
                  { Gap: 0, Align: "Center" }
                  [TEXT: new_dep_time]
                    ATTR: Variant("h3"), Weight("bold")
                    CONTENT: "{{item.departure_time|}}"
                  [TEXT: new_dep_city]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{item.departure_city|}}"
                [STACK: new_duration_info]
                  { Gap: 0, Align: "Center" }
                  [TEXT: new_duration]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{item.duration_label|}}"
                  [ICON: arrow_right_icon]
                    ATTR: Name("arrow-right"), Size("xs")
                [STACK: new_arrival_info]
                  { Gap: 0, Align: "Center" }
                  [TEXT: new_arr_time]
                    ATTR: Variant("h3"), Weight("bold")
                    CONTENT: "{{item.arrival_time|}}"
                  [TEXT: new_arr_city]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{item.arrival_city|}}"
          [CARD_FOOTER: change_card_footer]
            [FLEX: change_footer_row]
              { Justify: "Between", Align: "Center" }
              [FLEX: transport_tags]
                { Gap: 1, Wrap: true }
                [BADGE: cabin_badge]
                  ATTR: Variant("outline")
                  CONTENT: "{{item.cabin_class_label|}}"
                [BADGE: change_fee_badge]
                  ATTR: Variant("secondary")
                  CONTENT: "改签费 ¥{{item.change_fee|}}"
              [FLEX: new_price_row]
                { Gap: 1, Align: "Baseline" }
                [TEXT: new_currency]
                  ATTR: Variant("caption")
                  CONTENT: "¥"
                [TEXT: new_price]
                  ATTR: Variant("h3"), Color("primary")
                  CONTENT: "{{item.listed_price|}}"
      [/FOR]

  # 空状态
  OVERRIDE: empty_section
    [IF: results.total_count == 0]
      [EMPTY_STATE: no_change_results]
        ATTR: Title("未找到可改签班次"), Description("请调整日期或城市后重试"), Icon("refresh-cw")
    [/IF]

  # 覆写底部排序栏
  OVERRIDE: sort_bar_section
    [CONTROL_BAR: change_sort_bar]
      ATTR: Position("sticky_bottom")
      [FLEX: change_sort_buttons]
        { Gap: 3, Justify: "SpaceAround", Width: "full" }
        [BUTTON: change_sort_price]
          ATTR: Variant("ghost"), Icon("arrow-up-down"), Click("sort_by_price")
          CONTENT: "价格"
        [BUTTON: change_sort_departure]
          ATTR: Variant("ghost"), Icon("arrow-up-down"), Click("sort_by_departure")
          CONTENT: "出发时间"
        [BUTTON: change_sort_arrival]
          ATTR: Variant("ghost"), Icon("arrow-up-down"), Click("sort_by_arrival")
          CONTENT: "到达时间"
        [BUTTON: change_sort_fee]
          ATTR: Variant("ghost"), Icon("dollar-sign"), Click("sort_by_change_fee")
          CONTENT: "改签费"
