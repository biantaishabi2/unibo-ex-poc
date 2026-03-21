[PAGE: booking_confirmation]
  META: Entity("TravelOrder"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("预订结果")

  [SECTION: main_content]
    { Padding: 3 }
    [STACK: content_stack]
      { Gap: 3 }

      [CARD: status_card]
        [CARD_CONTENT: status_content]
          [STACK: status_stack]
            { Gap: 2, Align: "Center", Padding: 4 }
            [IF: order_booking_success]
              [ICON: success_icon]
                ATTR: Name("check-circle"), Size("lg"), Color("success")
              [TEXT: success_text]
                ATTR: Variant("h2"), Weight("bold")
                CONTENT: "预订成功"
            [/IF]
            [IF: order_status_failed]
              [ICON: fail_icon]
                ATTR: Name("x-circle"), Size("lg"), Color("destructive")
              [TEXT: fail_text]
                ATTR: Variant("h2"), Weight("bold")
                CONTENT: "预订失败"
              [TEXT: fail_hint]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "请稍后重试或联系客服"
            [/IF]

      [CARD: summary_card]
        [CARD_HEADER: summary_header]
          [TEXT: summary_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "订单摘要"
        [CARD_CONTENT: summary_content]
          [STACK: summary_stack]
            { Gap: 2 }
            [FLEX: order_no_row]
              { Justify: "Between" }
              [TEXT: order_no_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "订单号"
              [TEXT: order_no_value]
                CONTENT: "{{order.order_no|}}"
            [SEPARATOR: sep_1]
            [FLEX: product_type_row]
              { Justify: "Between" }
              [TEXT: product_type_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "产品类型"
              [BADGE: product_type_badge]
                ATTR: Variant("secondary")
                CONTENT: "{{order.product_type|}}"
            [SEPARATOR: sep_2]
            [IF: is_flight_order]
              [FLEX: flight_row]
                { Justify: "Between" }
                [TEXT: flight_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "航班"
                [TEXT: flight_value]
                  CONTENT: "{{order.flight_offer.flight_no|}}"
            [/IF]
            [IF: is_hotel_order]
              [FLEX: hotel_row]
                { Justify: "Between" }
                [TEXT: hotel_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "酒店"
                [TEXT: hotel_value]
                  CONTENT: "{{order.hotel_offer.hotel_name|}}"
            [/IF]
            [IF: is_train_order]
              [FLEX: train_row]
                { Justify: "Between" }
                [TEXT: train_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "车次"
                [TEXT: train_value]
                  CONTENT: "{{order.train_offer.train_no|}}"
            [/IF]
            [SEPARATOR: sep_3]
            [FLEX: traveler_count_row]
              { Justify: "Between" }
              [TEXT: traveler_count_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "出行人数"
              [TEXT: traveler_count_value]
                CONTENT: "{{order.traveler_count|}}"
            [SEPARATOR: sep_4]
            [FLEX: amount_row]
              { Justify: "Between" }
              [TEXT: amount_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "订单金额"
              [TEXT: amount_value]
                ATTR: Variant("h3"), Color("primary")
                CONTENT: "{{order.total_amount|}}"

      [STACK: action_buttons]
        { Gap: 2 }
        [BUTTON: view_order_btn]
          ATTR: Variant("primary"), Size("lg"), FullWidth("true"), Click("navigate:/travel/orders/{{order.id|}}")
          CONTENT: "查看订单"
        [BUTTON: go_home_btn]
          ATTR: Variant("outline"), Size("lg"), FullWidth("true"), Click("navigate:/travel")
          CONTENT: "回到首页"
