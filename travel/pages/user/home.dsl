[PAGE: home]
  ATTR: Title("差旅")

  [SECTION: search_section]
    [TABS: search_tabs]
      ATTR: Default("flight")
      [TABS_LIST: tab_list]
        [TABS_TRIGGER: trigger_flight]
          ATTR: Value("flight")
          CONTENT: "机票"
        [TABS_TRIGGER: trigger_hotel]
          ATTR: Value("hotel")
          CONTENT: "酒店"
        [TABS_TRIGGER: trigger_train]
          ATTR: Value("train")
          CONTENT: "火车票"
      [TABS_CONTENT: flight_tab_content]
        ATTR: Value("flight")
        [STACK: flight_form]
          { Gap: 4 }
          [STACK: flight_fields]
            { Gap: 3 }
            [INPUT: departure_city_input]
              ATTR: Label("出发城市"), Placeholder("请选择出发城市"), Bind("form.departure_city")
            [INPUT: arrival_city_input]
              ATTR: Label("目的城市"), Placeholder("请选择目的城市"), Bind("form.arrival_city")
            [INPUT: departure_date_input]
              ATTR: Label("出发日期"), Placeholder("请选择日期"), Bind("form.departure_date"), Type("date")
            [FLEX: direct_only_row]
              { Gap: 2, Align: "Center" }
              [SWITCH: direct_only_switch]
                ATTR: Label("仅看直飞"), Bind("form.direct_only")
            [BUTTON: search_flight_btn]
              ATTR: Variant("primary"), Size("lg"), Click("navigate:/travel/flight/search")
              CONTENT: "因公出行·搜索机票"
      [TABS_CONTENT: hotel_tab_content]
        ATTR: Value("hotel")
        [STACK: hotel_form]
          { Gap: 4 }
          [STACK: hotel_fields]
            { Gap: 3 }
            [INPUT: hotel_city_input]
              ATTR: Label("城市"), Placeholder("请选择城市"), Bind("form.hotel_city")
            [FLEX: hotel_date_row]
              { Gap: 2 }
              [INPUT: checkin_date_input]
                ATTR: Label("入住日期"), Placeholder("请选择"), Bind("form.checkin_date"), Type("date")
              [INPUT: checkout_date_input]
                ATTR: Label("退房日期"), Placeholder("请选择"), Bind("form.checkout_date"), Type("date")
            [INPUT: hotel_keyword_input]
              ATTR: Label("关键词"), Placeholder("酒店名/商圈/地标"), Bind("form.hotel_keyword")
            [BUTTON: search_hotel_btn]
              ATTR: Variant("primary"), Size("lg"), Click("navigate:/travel/hotel/search")
              CONTENT: "因公出行·搜索酒店"
      [TABS_CONTENT: train_tab_content]
        ATTR: Value("train")
        [STACK: train_form]
          { Gap: 4 }
          [STACK: train_fields]
            { Gap: 3 }
            [INPUT: departure_station_input]
              ATTR: Label("出发站"), Placeholder("请选择出发站"), Bind("form.departure_station")
            [INPUT: arrival_station_input]
              ATTR: Label("到达站"), Placeholder("请选择到达站"), Bind("form.arrival_station")
            [INPUT: train_date_input]
              ATTR: Label("出发日期"), Placeholder("请选择日期"), Bind("form.train_date"), Type("date")
            [FLEX: high_speed_row]
              { Gap: 2, Align: "Center" }
              [SWITCH: high_speed_switch]
                ATTR: Label("只看高铁动车"), Bind("form.high_speed_only")
            [BUTTON: search_train_btn]
              ATTR: Variant("primary"), Size("lg"), Click("navigate:/travel/train/search")
              CONTENT: "因公出行·搜索火车票"

  [SECTION: bottom_nav]
    [FLEX: nav_bar]
      { Justify: "Around" }
      [BUTTON: nav_home]
        ATTR: Variant("ghost"), Icon("home"), Click("navigate:/travel")
        CONTENT: "首页"
      [BUTTON: nav_trips]
        ATTR: Variant("ghost"), Icon("calendar"), Click("navigate:/travel/trips")
        CONTENT: "行程"
      [BUTTON: nav_orders]
        ATTR: Variant("ghost"), Icon("list"), Click("navigate:/travel/orders")
        CONTENT: "订单"
      [BUTTON: nav_profile]
        ATTR: Variant("ghost"), Icon("user"), Click("navigate:/travel/profile")
        CONTENT: "我的"
