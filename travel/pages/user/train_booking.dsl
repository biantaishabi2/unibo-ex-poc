# 火车票预订页
# 车次摘要 + 差标提示 + 乘车人 + 联系人 + 选座偏好 + 支付 + 底部提交栏

[PAGE: train_booking]
  EXTENDS: base_booking_form

  OVERRIDE: section("summary_section")
    [CARD: train_summary_card]
      [CARD_HEADER: train_summary_ch]
        [FLEX: train_header_flex]
          { Gap: 2, Align: "Center" }
          [TEXT: train_no_text]
            ATTR: Variant("body"), Weight("bold")
            CONTENT: "{{offer.train_no|}}"
          [BADGE: train_type_badge]
            ATTR: Variant("outline")
            CONTENT: "{{offer.train_type_label|}}"
          [BADGE: seat_class_badge]
            ATTR: Variant("secondary")
            CONTENT: "{{offer.selected_seat_class_name|}}"
      [CARD_CONTENT: train_summary_cc]
        [FLEX: train_route_flex]
          { Justify: "Between", Align: "Center" }
          [STACK: train_departure_stack]
            { Gap: 0, Align: "Center" }
            [TEXT: train_departure_time]
              ATTR: Variant("h2"), Weight("bold")
              CONTENT: "{{offer.departure_time|}}"
            [TEXT: train_departure_station]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{offer.departure_station_name|}}"
          [STACK: train_middle_stack]
            { Gap: 0, Align: "Center" }
            [TEXT: train_date_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{offer.date_label|}}"
            [ICON: arrow_icon]
              ATTR: Name("arrow-right"), Size("sm")
          [STACK: train_arrival_stack]
            { Gap: 0, Align: "Center" }
            [TEXT: train_arrival_time]
              ATTR: Variant("h2"), Weight("bold")
              CONTENT: "{{offer.arrival_time|}}"
            [TEXT: train_arrival_station]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{offer.arrival_station_name|}}"
      [CARD_FOOTER: train_summary_cf]
        [FLEX: train_price_flex]
          { Justify: "End", Align: "Baseline" }
          [TEXT: train_currency]
            ATTR: Variant("caption")
            CONTENT: "{{offer.currency|}}"
          [TEXT: train_seat_price]
            ATTR: Variant("h2"), Color("primary")
            CONTENT: "{{offer.selected_seat_price|}}"

  OVERRIDE: section("policy_alert_section")
    [IF: offer.is_policy_exceeded == true]
      [ALERT: train_policy_alert]
        ATTR: Variant("warning"), Title("超出差旅标准"), Description("该席别超出您的差旅标准，提交后需经审批")
    [/IF]

  OVERRIDE: section("traveler_section")
    [CARD: rider_card]
      [CARD_HEADER: rider_ch]
        [FLEX: rider_header_flex]
          { Justify: "Between", Align: "Center" }
          [TEXT: rider_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "乘车人"
          [BUTTON: btn_add_rider]
            ATTR: Variant("ghost"), Size("sm"), Click("add_traveler")
            CONTENT: "+ 添加"
      [CARD_CONTENT: rider_cc]
        [STACK: rider_list_stack]
          { Gap: 2 }
          [FOR: item in travelers.items]
            [FLEX: rider_item_flex]
              { Gap: 2, Align: "Center", PaddingY: 2 }
              [CHECKBOX: rider_cb]
                ATTR: Bind("item.selected")
              [AVATAR: rider_avatar]
                ATTR: Src("{{item.avatar|}}"), Fallback("{{item.name_initial|}}"), Size("sm")
              [STACK: rider_info_stack]
                { Gap: 0 }
                [TEXT: rider_name]
                  ATTR: Variant("body")
                  CONTENT: "{{item.name|}}"
                [TEXT: rider_id_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.id_type_label|}}"
          [/FOR]

  OVERRIDE: section("extra_options_section")
    [CARD: seat_pref_card]
      [CARD_HEADER: seat_pref_ch]
        [TEXT: seat_pref_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "选座偏好"
      [CARD_CONTENT: seat_pref_cc]
        [SELECT: select_seat_preference]
          ATTR: Label("座位偏好"), Bind("form.seat_preference")
          CONTENT: "无偏好:no_preference,靠窗:window,靠过道:aisle"
