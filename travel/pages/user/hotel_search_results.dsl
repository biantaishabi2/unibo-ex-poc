# 酒店搜索结果页
# 按条件搜索酒店列表，支持筛选排序
# 结构与机票/火车票差异较大（无日期横滑、无底部排序栏、有图片卡片），不使用 EXTENDS

[PAGE: hotel_search_results]
  ATTR: Title("酒店搜索")
  META: Entity("HotelOffer"), Domain("Travel")

  # 顶部导航
  [SECTION: header_section]
    [HEADER: hotel_header]
      ATTR: Back(true), Title("酒店搜索")

  # 搜索条件摘要
  [SECTION: search_summary_section]
    [FLEX: search_summary]
      { Gap: 2, Padding: 3, Align: "Center", Background: "surface" }
      [BADGE: checkin_date_badge]
        ATTR: Variant("outline")
        CONTENT: "{{search.checkin_date|}}"
      [TEXT: date_separator]
        CONTENT: "-"
      [BADGE: checkout_date_badge]
        ATTR: Variant("outline")
        CONTENT: "{{search.checkout_date|}}"
      [INPUT: keyword_input]
        ATTR: Placeholder("酒店名/商圈/地标"), Bind("search.keyword"), Size("sm")

  # 筛选栏
  [SECTION: filter_section]
    [FLEX: hotel_filter_bar]
      { Gap: 2, PaddingX: 3, PaddingY: 2, Wrap: true }
      [SELECT: filter_sort_by]
        ATTR: Label("排序"), Name("filter.sort_by")
      [SELECT: filter_area]
        ATTR: Label("区域"), Name("filter.area")
      [SELECT: filter_price_star]
        ATTR: Label("价格星级"), Name("filter.price_star")
      [SELECT: filter_hotel_policy]
        ATTR: Label("差标"), Name("filter.policy_compliant")
      [SELECT: filter_agreement]
        ATTR: Label("协议酒店"), Name("filter.agreement_hotel")

  # 超标提示
  [SECTION: alert_section]
    [IF: policy.exceeded == true]
      [ALERT: hotel_policy_alert]
        ATTR: Variant("warning"), Title("超标提示")
        CONTENT: "以下标记超标的酒店超出差旅标准，预订需审批"
    [/IF]

  # 酒店卡片列表
  [SECTION: results_section]
    [STACK: hotel_results_list]
      { Gap: 3, Padding: 3 }
      [FOR: item in hotels.items]
        [CARD: hotel_card]
          ATTR: Click("navigate"), Params("/travel/hotel/{{item.hotel_code|}}")
          [CARD_HEADER: hotel_card_header]
            [IMAGE: hotel_cover]
              ATTR: Src("{{item.hotel_ref.cover_image|}}"), Alt("{{item.hotel_name|}}"), AspectRatio("16:9"), BorderRadius("top")
          [CARD_CONTENT: hotel_card_content]
            [STACK: hotel_info_stack]
              { Gap: 2 }
              # 酒店名称+星级
              [FLEX: hotel_name_row]
                { Gap: 2, Align: "Center" }
                [TEXT: hotel_name]
                  ATTR: Variant("h4"), Weight("bold")
                  CONTENT: "{{item.hotel_name|}}"
                [BADGE: hotel_star_badge]
                  ATTR: Variant("secondary")
                  CONTENT: "{{item.hotel_ref.hotel_star|}}"
              # 评分+地址
              [FLEX: hotel_score_row]
                { Gap: 2, Align: "Center" }
                [BADGE: hotel_score_badge]
                  ATTR: Variant("primary")
                  CONTENT: "{{item.hotel_ref.score|}}"
                [TEXT: hotel_address]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.hotel_ref.address|}}"
              # 设施标签
              [FLEX: hotel_facilities_row]
                { Gap: 1, Wrap: true }
                [FOR: facility in item.hotel_ref.facilities]
                  [BADGE: facility_badge]
                    ATTR: Variant("outline")
                    CONTENT: "{{facility.name|}}"
                [/FOR]
          [CARD_FOOTER: hotel_card_footer]
            [FLEX: hotel_footer_row]
              { Justify: "Between", Align: "Center" }
              [IF: item.is_agreement == true]
                [BADGE: agreement_badge]
                  ATTR: Variant("success")
                  CONTENT: "协议酒店"
              [/IF]
              [FLEX: hotel_price]
                { Gap: 1, Align: "Baseline" }
                [TEXT: hotel_currency]
                  ATTR: Variant("caption")
                  CONTENT: "{{item.currency|}}"
                [TEXT: hotel_listed_price]
                  ATTR: Variant("h3"), Color("primary")
                  CONTENT: "{{item.listed_price|}}"
                [TEXT: hotel_price_suffix]
                  ATTR: Variant("caption")
                  CONTENT: "起"
      [/FOR]

  # 空状态
  [SECTION: empty_section]
    [IF: hotels.total_count == 0]
      [EMPTY_STATE: no_hotels]
        ATTR: Title("未找到酒店"), Description("请调整搜索条件后重试"), Icon("search")
    [/IF]
