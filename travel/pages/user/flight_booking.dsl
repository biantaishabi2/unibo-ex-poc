# 机票预订页
# 航班摘要 + 退改政策 + 乘机人 + 联系人 + 支付 + 底部提交栏

[PAGE: flight_booking]
  EXTENDS: base_booking_form
  META: Entity("FlightOffer"), Domain("Travel")
  BIND: Form("create")

  OVERRIDE: section("summary_section")
    [CARD: flight_summary_card]
      [CARD_HEADER: flight_summary_ch]
        [FLEX: flight_header_flex]
          { Gap: 2, Align: "Center" }
          [AVATAR: airline_avatar]
            ATTR: Src("{{offer.airline_ref.logo|}}"), Fallback("{{offer.airline_ref.code|}}"), Size("sm")
          [TEXT: flight_no_text]
            ATTR: Variant("body"), Weight("bold")
            CONTENT: "{{offer.flight_no|}}"
          [BADGE: cabin_class_badge]
            ATTR: Variant("secondary")
            CONTENT: "{{offer.cabin_class_ref.name|}}"
      [CARD_CONTENT: flight_summary_cc]
        [FLEX: flight_route_flex]
          { Justify: "Between", Align: "Center" }
          [STACK: departure_stack]
            { Gap: 0, Align: "Center" }
            [TEXT: departure_time]
              ATTR: Variant("h2"), Weight("bold")
              CONTENT: "{{offer.departure_time|}}"
            [TEXT: departure_airport]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{offer.departure_airport_code|}}"
          [STACK: middle_stack]
            { Gap: 0, Align: "Center" }
            [TEXT: date_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{offer.date_label|}}"
            [ICON: plane_icon]
              ATTR: Name("plane"), Size("sm")
          [STACK: arrival_stack]
            { Gap: 0, Align: "Center" }
            [TEXT: arrival_time]
              ATTR: Variant("h2"), Weight("bold")
              CONTENT: "{{offer.arrival_time|}}"
            [TEXT: arrival_airport]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{offer.arrival_airport_code|}}"
      [CARD_FOOTER: flight_summary_cf]
        [FLEX: flight_price_flex]
          { Justify: "End", Align: "Baseline" }
          [TEXT: flight_currency]
            ATTR: Variant("caption")
            CONTENT: "{{offer.currency|}}"
          [TEXT: flight_listed_price]
            ATTR: Variant("h2"), Color("primary")
            CONTENT: "{{offer.listed_price|}}"

  OVERRIDE: section("policy_alert_section")
    # 退改政策
    [CARD: refund_policy_card]
      [CARD_HEADER: refund_policy_ch]
        [TEXT: refund_policy_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "退改政策"
      [CARD_CONTENT: refund_policy_cc]
        [STACK: refund_policy_stack]
          { Gap: 2 }
          [FLEX: refund_stats_flex]
            { Gap: 2 }
            [STATISTIC: refund_stat]
              ATTR: Title("退票"), Value("{{offer.refund_change_policy.refund_label|}}")
            [STATISTIC: change_stat]
              ATTR: Title("改签"), Value("{{offer.refund_change_policy.change_label|}}")
          [FLEX: fare_badges_flex]
            { Gap: 1, Wrap: "true" }
            [BADGE: baggage_badge]
              ATTR: Variant("outline")
              CONTENT: "{{offer.baggage_policy|}}"
            [BADGE: fare_family_badge]
              ATTR: Variant("outline")
              CONTENT: "{{offer.fare_family|}}"
    # 差标提示
    [IF: offer.is_policy_exceeded == true]
      [ALERT: policy_exceeded_alert]
        ATTR: Variant("warning"), Title("超出差旅标准"), Description("该舱位超出您的差旅标准，提交后需经审批")
    [/IF]

  OVERRIDE: section("traveler_section")
    [CARD: passenger_card]
      [CARD_HEADER: passenger_ch]
        [FLEX: passenger_header_flex]
          { Justify: "Between", Align: "Center" }
          [TEXT: passenger_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "乘机人"
          [BUTTON: btn_add_passenger]
            ATTR: Variant("ghost"), Size("sm"), Click("add_traveler")
            CONTENT: "+ 添加"
      [CARD_CONTENT: passenger_cc]
        [STACK: passenger_list_stack]
          { Gap: 2 }
          [FOR: item in travelers.items]
            [FLEX: passenger_item_flex]
              { Gap: 2, Align: "Center", PaddingY: 2 }
              [CHECKBOX: passenger_cb]
                ATTR: Bind("item.selected")
              [AVATAR: passenger_avatar]
                ATTR: Src("{{item.avatar|}}"), Fallback("{{item.name_initial|}}"), Size("sm")
              [STACK: passenger_info_stack]
                { Gap: 0 }
                [TEXT: passenger_name]
                  ATTR: Variant("body")
                  CONTENT: "{{item.name|}}"
                [TEXT: passenger_id_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.id_type_label|}}"
          [/FOR]
