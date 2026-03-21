[PAGE: hotel_detail]
  META: Entity("HotelOffer"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("酒店详情")

  [SECTION: hotel_cover]
    [IMAGE: cover_image]
      ATTR: Src("{{hotel.cover_image|}}"), Alt("{{hotel.hotel_name|}}")

  [SECTION: hotel_info]
    [STACK: hotel_basic]
      { Gap: 2 }
      [FLEX: hotel_name_row]
        { Gap: 2, Align: "Center" }
        [TEXT: hotel_name]
          ATTR: Variant("h2"), Weight("bold")
          CONTENT: "{{hotel.hotel_name|}}"
        [BADGE: hotel_star]
          ATTR: Variant("secondary")
          CONTENT: "{{hotel.hotel_star|}}"

      [TABS: photo_tabs]
        ATTR: Default("exterior")
        [TABS_LIST: photo_tab_list]
          [TABS_TRIGGER: trigger_exterior]
            ATTR: Value("exterior")
            CONTENT: "外观"
          [TABS_TRIGGER: trigger_dining]
            ATTR: Value("dining")
            CONTENT: "餐饮"
          [TABS_TRIGGER: trigger_room]
            ATTR: Value("room")
            CONTENT: "客房"
        [TABS_CONTENT: exterior_content]
          ATTR: Value("exterior")
          [IMAGE: exterior_img]
            ATTR: Src("{{hotel.exterior_image|}}"), Alt("外观")
        [TABS_CONTENT: dining_content]
          ATTR: Value("dining")
          [IMAGE: dining_img]
            ATTR: Src("{{hotel.dining_image|}}"), Alt("餐饮")
        [TABS_CONTENT: room_content_tab]
          ATTR: Value("room")
          [IMAGE: room_img]
            ATTR: Src("{{hotel.room_image|}}"), Alt("客房")

      [FLEX: score_row]
        { Gap: 2, Align: "Center" }
        [BADGE: hotel_score]
          ATTR: Variant("primary")
          CONTENT: "{{hotel.score|}}"
        [TEXT: score_label]
          ATTR: Variant("body"), Color("primary")
          CONTENT: "{{hotel.score_label|}}"

      [FLEX: address_row]
        { Gap: 1, Align: "Center" }
        [ICON: map_pin_icon]
          ATTR: Name("map-pin"), Size("sm"), Color("muted")
        [TEXT: hotel_address]
          ATTR: Variant("caption"), Color("muted")
          CONTENT: "{{hotel.address|}}"

  [SEPARATOR: sep_1]

  [SECTION: date_filter]
    [FLEX: filter_row]
      { Gap: 2, Align: "Center" }
      [INPUT: checkin_input]
        ATTR: Label("入住"), Bind("filter.checkin_date"), Type("date")
      [INPUT: checkout_input]
        ATTR: Label("退房"), Bind("filter.checkout_date"), Type("date")
      [BUTTON: refresh_btn]
        ATTR: Variant("outline"), Click("refresh_offers")
        CONTENT: "查询"

  [SEPARATOR: sep_2]

  [SECTION: room_list_section]
    [TEXT: room_list_title]
      ATTR: Variant("h3")
      CONTENT: "房型报价"

    [STACK: room_list]
      { Gap: 3 }
      [FOR: item in offers]
        [CARD: room_card]
          [CARD_HEADER: room_header]
            [FLEX: room_header_flex]
              { Gap: 3 }
              [STACK: room_info_stack]
                { Gap: 1 }
                [TEXT: room_type_name]
                  ATTR: Variant("h4"), Weight("bold")
                  CONTENT: "{{item.room_type_name|}}"
                [TEXT: bed_type]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.bed_type|}}"
                [FLEX: room_badges]
                  { Gap: 1 }
                  [BADGE: area_badge]
                    ATTR: Variant("outline")
                    CONTENT: "{{item.area_label|}}"
                  [BADGE: floor_badge]
                    ATTR: Variant("outline")
                    CONTENT: "{{item.floor_label|}}"
          [CARD_CONTENT: room_content]
            [FLEX: rate_row]
              { Justify: "Between", Align: "Center" }
              [STACK: rate_info]
                { Gap: 1 }
                [TEXT: rate_plan]
                  ATTR: Variant("body"), Weight("bold")
                  CONTENT: "{{item.rate_plan_code|}}"
                [FLEX: rate_badges]
                  { Gap: 1 }
                  [BADGE: cancel_policy_badge]
                    ATTR: Variant("outline")
                    CONTENT: "{{item.cancellation_policy|}}"
                  [IF: item.is_breakfast_included]
                    [BADGE: breakfast_badge]
                      ATTR: Variant("success")
                      CONTENT: "含早"
                  [/IF]
                  [IF: item.exceeds_policy]
                    [BADGE: exceed_badge]
                      ATTR: Variant("destructive")
                      CONTENT: "超标"
                  [/IF]
              [FLEX: price_action]
                { Gap: 2, Align: "Center" }
                [FLEX: price_display]
                  { Gap: 1, Align: "Baseline" }
                  [TEXT: currency]
                    ATTR: Variant("caption")
                    CONTENT: "{{item.currency|}}"
                  [TEXT: listed_price]
                    ATTR: Variant("h3"), Color("primary")
                    CONTENT: "{{item.listed_price|}}"
                [BUTTON: book_btn]
                  ATTR: Variant("primary"), Size("sm"), Click("navigate:/travel/hotel/booking/{{item.id|}}")
                  CONTENT: "预订"
      [/FOR]

    [IF: offers_empty]
      [EMPTY_STATE: no_rooms]
        ATTR: Title("暂无可用房型"), Description("请调整日期后重试"), Icon("bed")
    [/IF]
