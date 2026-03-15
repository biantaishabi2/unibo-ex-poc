[PAGE: train_detail]
  ATTR: Title("车次详情")

  [SECTION: route_summary]
    { Background: "primary", Padding: 4 }
    [FLEX: route_display]
      { Justify: "Between", Align: "Center" }
      [STACK: departure_info]
        { Gap: 0, Align: "Center" }
        [TEXT: departure_time]
          ATTR: Variant("h1"), Weight("bold"), Color("white")
          CONTENT: "{{offer.departure_time|}}"
        [TEXT: departure_station]
          ATTR: Variant("body"), Color("white")
          CONTENT: "{{offer.departure_station_name|}}"
      [STACK: train_indicator]
        { Gap: 0, Align: "Center" }
        [TEXT: duration_label]
          ATTR: Variant("caption"), Color("white")
          CONTENT: "{{offer.duration_label|}}"
        [ICON: arrow_icon]
          ATTR: Name("arrow-right"), Color("white")
        [TEXT: date_label]
          ATTR: Variant("caption"), Color("white")
          CONTENT: "{{offer.date_label|}}"
      [STACK: arrival_info]
        { Gap: 0, Align: "Center" }
        [TEXT: arrival_time]
          ATTR: Variant("h1"), Weight("bold"), Color("white")
          CONTENT: "{{offer.arrival_time|}}"
        [TEXT: arrival_station]
          ATTR: Variant("body"), Color("white")
          CONTENT: "{{offer.arrival_station_name|}}"

  [SECTION: train_info_section]
    [CARD: train_info_card]
      [CARD_HEADER: train_info_header]
        [TEXT: info_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "车次信息"
      [CARD_CONTENT: train_info_content]
        [GRID: info_grid]
          { Columns: 2, Gap: 3 }
          [FLEX: train_no_stat]
            { Gap: 1 }
            [TEXT: train_no_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "车次号"
            [TEXT: train_no_value]
              ATTR: Variant("body")
              CONTENT: "{{offer.train_no|}}"
          [FLEX: train_type_stat]
            { Gap: 1 }
            [TEXT: train_type_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "车次类型"
            [TEXT: train_type_value]
              ATTR: Variant("body")
              CONTENT: "{{offer.train_type_label|}}"
          [FLEX: dep_station_stat]
            { Gap: 1 }
            [TEXT: dep_station_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "出发站"
            [TEXT: dep_station_value]
              ATTR: Variant("body")
              CONTENT: "{{offer.departure_station_name|}}"
          [FLEX: arr_station_stat]
            { Gap: 1 }
            [TEXT: arr_station_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "到达站"
            [TEXT: arr_station_value]
              ATTR: Variant("body")
              CONTENT: "{{offer.arrival_station_name|}}"

  [SEPARATOR: sep_1]

  [SECTION: seat_list_section]
    [TEXT: seat_list_title]
      ATTR: Variant("h3"), Padding("3")
      CONTENT: "选择席别"

    [STACK: seat_list]
      { Gap: 2, Padding: 3 }
      [FOR: item in offer.seat_options]
        [CARD: seat_card]
          [CARD_CONTENT: seat_content]
            [FLEX: seat_row]
              { Justify: "Between", Align: "Center" }
              [STACK: seat_info]
                { Gap: 1 }
                [FLEX: seat_name_row]
                  { Gap: 2, Align: "Center" }
                  [TEXT: seat_class_name]
                    ATTR: Variant("body"), Weight("bold")
                    CONTENT: "{{item.seat_class_name|}}"
                  [IF: item.not_policy_compliant]
                    [BADGE: exceed_badge]
                      ATTR: Variant("destructive")
                      CONTENT: "超标"
                  [/IF]
                [TEXT: tickets_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.tickets_label|}}"
              [STACK: seat_price_col]
                { Gap: 1, Align: "End" }
                [FLEX: price_display]
                  { Gap: 1, Align: "Baseline" }
                  [TEXT: currency]
                    ATTR: Variant("caption")
                    CONTENT: "{{item.currency|}}"
                  [TEXT: price]
                    ATTR: Variant("h3"), Color("primary")
                    CONTENT: "{{item.price|}}"
                [BUTTON: book_btn]
                  ATTR: Variant("primary"), Size("sm"), Click("navigate:/travel/train/booking/{{item.offer_id|}}")
                  CONTENT: "预订"
      [/FOR]
