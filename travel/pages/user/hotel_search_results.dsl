EXTENDS: base_search_results
META: Entity("HotelOffer"), Domain("Travel")

[PAGE: hotel_search_results]
  ATTR: Title("酒店搜索")

  # 覆写顶部导航
  OVERRIDE: section("header_section")
    [HEADER: hotel_header]
      ATTR: Back(true), Title("酒店搜索"), Subtitle("{{search.city_label|}}")

  # 覆写日期横滑条 — 入住/离店日期
  OVERRIDE: section("date_slider_section")
    [FLEX: hotel_date_bar]
      { Gap: 3, PaddingX: 3, PaddingY: 2, Align: "Center", Background: "surface" }
      [STACK: checkin_info]
        { Gap: 0, Align: "Center" }
        [TEXT: checkin_label]
          ATTR: Variant("caption"), Color("muted")
          CONTENT: "入住"
        [TEXT: checkin_date]
          ATTR: Variant("body"), Weight("bold")
          CONTENT: "{{search.checkin_date|}}"
      [TEXT: night_count]
        ATTR: Variant("caption"), Color("muted")
        CONTENT: "{{search.night_count_label|}}"
      [STACK: checkout_info]
        { Gap: 0, Align: "Center" }
        [TEXT: checkout_label]
          ATTR: Variant("caption"), Color("muted")
          CONTENT: "离店"
        [TEXT: checkout_date]
          ATTR: Variant("body"), Weight("bold")
          CONTENT: "{{search.checkout_date|}}"

  # 覆写筛选栏
  OVERRIDE: section("filter_section")
    [FLEX: hotel_filter_bar]
      { Gap: 2, PaddingX: 3, PaddingY: 2, Wrap: true }
      [SELECT: filter_star]
        ATTR: Label("星级"), Name("filter.star")
      [SELECT: filter_price_range]
        ATTR: Label("价格"), Name("filter.price_range")
      [SELECT: filter_district]
        ATTR: Label("商圈"), Name("filter.district")
      [SELECT: filter_brand]
        ATTR: Label("品牌"), Name("filter.brand")

  # 覆写超标提示
  OVERRIDE: section("alert_section")
    [IF: policy.exceeded == true]
      [ALERT: hotel_policy_alert]
        ATTR: Variant("warning"), Title("超标提示")
        CONTENT: "标记超标的酒店超出差旅标准，预订需审批"
    [/IF]

  # 覆写结果列表 — 酒店卡片
  OVERRIDE: section("results_section")
    [STACK: hotel_results_list]
      { Gap: 3, Padding: 3 }
      [FOR: item in hotels.items]
        [CARD: hotel_card]
          ATTR: Click("navigate"), Params("/travel/hotel/{{item.id|}}")
          [CARD_HEADER: hotel_card_header]
            [FLEX: hotel_name_row]
              { Gap: 2, Align: "Center" }
              [TEXT: hotel_name]
                ATTR: Variant("body"), Weight("bold")
                CONTENT: "{{item.hotel_name|}}"
              [BADGE: hotel_star_badge]
                ATTR: Variant("outline")
                CONTENT: "{{item.hotel_star|}}"
              [IF: item.is_policy_compliant == false]
                [BADGE: hotel_exceed_badge]
                  ATTR: Variant("destructive")
                  CONTENT: "超标"
              [/IF]
          [CARD_CONTENT: hotel_card_content]
            [STACK: hotel_detail_stack]
              { Gap: 1 }
              [TEXT: hotel_address]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{item.address|}}"
              [TEXT: hotel_district]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{item.district|}}"
              [FLEX: hotel_tags_row]
                { Gap: 1, Wrap: true }
                [BADGE: hotel_room_type]
                  ATTR: Variant("outline")
                  CONTENT: "{{item.room_type_name|}}"
                [BADGE: hotel_breakfast]
                  ATTR: Variant("outline")
                  CONTENT: "{{item.breakfast_label|}}"
                [BADGE: hotel_cancel_policy]
                  ATTR: Variant("outline")
                  CONTENT: "{{item.cancel_label|}}"
          [CARD_FOOTER: hotel_card_footer]
            [FLEX: hotel_price_row]
              { Justify: "Between", Align: "Baseline" }
              [TEXT: hotel_rating]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{item.rating_label|}}"
              [FLEX: hotel_price]
                { Gap: 1, Align: "Baseline" }
                [TEXT: hotel_currency]
                  ATTR: Variant("caption")
                  CONTENT: "¥"
                [TEXT: hotel_listed_price]
                  ATTR: Variant("h3"), Color("primary")
                  CONTENT: "{{item.listed_price|}}"
                [TEXT: hotel_price_unit]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "/晚"
      [/FOR]

  # 覆写空状态
  OVERRIDE: section("empty_section")
    [IF: hotels.total_count == 0]
      [EMPTY_STATE: no_hotels]
        ATTR: Title("未找到酒店"), Description("请调整搜索条件后重试"), Icon("building")
    [/IF]

  # 覆写底部排序栏
  OVERRIDE: section("sort_bar_section")
    [CONTROL_BAR: hotel_sort_bar]
      ATTR: Position("sticky_bottom")
      [FLEX: hotel_sort_buttons]
        { Gap: 3, Justify: "SpaceAround", Width: "full" }
        [BUTTON: sort_by_hotel_price]
          ATTR: Variant("ghost"), Icon("arrow-up-down"), Click("sort")
          CONTENT: "价格"
        [BUTTON: sort_by_rating]
          ATTR: Variant("ghost"), Icon("star"), Click("sort")
          CONTENT: "评分"
        [BUTTON: sort_by_distance]
          ATTR: Variant("ghost"), Icon("map-pin"), Click("sort")
          CONTENT: "距离"
        [BUTTON: sort_by_hotel_recommended]
          ATTR: Variant("ghost"), Icon("thumbs-up"), Click("sort")
          CONTENT: "推荐"
