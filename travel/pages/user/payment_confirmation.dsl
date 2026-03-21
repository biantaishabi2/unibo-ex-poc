[PAGE: payment_confirmation]
  META: Entity("TravelOrder"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("支付确认")

  [SECTION: main_content]
    { Padding: 3 }
    [STACK: content_stack]
      { Gap: 3 }

      [CARD: status_card]
        [CARD_CONTENT: status_content]
          [STACK: status_stack]
            { Gap: 2, Align: "Center", Padding: 4 }
            [IF: payment_completed]
              [ICON: success_icon]
                ATTR: Name("check-circle"), Size("lg"), Color("success")
              [TEXT: success_text]
                ATTR: Variant("h2"), Weight("bold")
                CONTENT: "支付成功"
            [/IF]
            [IF: payment_pending]
              [ICON: pending_icon]
                ATTR: Name("clock"), Size("lg"), Color("warning")
              [TEXT: pending_text]
                ATTR: Variant("h2"), Weight("bold")
                CONTENT: "支付处理中"
            [/IF]
            [IF: payment_failed]
              [ICON: fail_icon]
                ATTR: Name("x-circle"), Size("lg"), Color("destructive")
              [TEXT: fail_text]
                ATTR: Variant("h2"), Weight("bold")
                CONTENT: "支付失败"
              [TEXT: fail_hint]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "请重试或选择其他支付方式"
            [/IF]

      [CARD: payment_method_card]
        [CARD_HEADER: method_header]
          [TEXT: method_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "支付方式"
        [CARD_CONTENT: method_content]
          [FLEX: method_row]
            { Justify: "Between", Align: "Center" }
            [FLEX: method_info]
              { Gap: 2, Align: "Center" }
              [ICON: building_icon]
                ATTR: Name("building"), Size("sm")
              [TEXT: company_pay_label]
                CONTENT: "公司支付"
            [BADGE: method_badge]
              ATTR: Variant("secondary")
              CONTENT: "{{order.payment.payment_method|}}"

      [CARD: fee_detail_card]
        [CARD_HEADER: fee_header]
          [TEXT: fee_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "费用明细"
        [CARD_CONTENT: fee_content]
          [STACK: fee_stack]
            { Gap: 2 }
            [FLEX: total_amount_row]
              { Justify: "Between" }
              [TEXT: total_amount_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "订单金额"
              [TEXT: total_amount_value]
                CONTENT: "{{order.total_amount|}}"
            [IF: has_points_deduction]
              [FLEX: points_row]
                { Justify: "Between" }
                [TEXT: points_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "积分抵扣"
                [TEXT: points_value]
                  ATTR: Color("success")
                  CONTENT: "{{order.points_deduction_amount|}}"
            [/IF]
            [SEPARATOR: fee_sep_1]
            [FLEX: payable_row]
              { Justify: "Between" }
              [TEXT: payable_label]
                ATTR: Variant("body"), Weight("bold")
                CONTENT: "实付金额"
              [TEXT: payable_value]
                ATTR: Variant("h3"), Color("primary")
                CONTENT: "{{order.payable_amount|}}"
            [SEPARATOR: fee_sep_2]
            [FLEX: currency_row]
              { Justify: "Between" }
              [TEXT: currency_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "币种"
              [TEXT: currency_value]
                CONTENT: "{{order.currency|}}"

      [IF: payment_completed]
        [CARD: payment_info_card]
          [CARD_HEADER: payment_info_header]
            [TEXT: payment_info_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "支付信息"
          [CARD_CONTENT: payment_info_content]
            [STACK: payment_info_stack]
              { Gap: 2 }
              [FLEX: payment_no_row]
                { Justify: "Between" }
                [TEXT: payment_no_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "支付单号"
                [TEXT: payment_no_value]
                  CONTENT: "{{order.payment.payment_no|}}"
              [FLEX: paid_at_row]
                { Justify: "Between" }
                [TEXT: paid_at_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "支付时间"
                [TEXT: paid_at_value]
                  CONTENT: "{{order.payment.paid_at|}}"
      [/IF]

  [SECTION: action_bar]
    [FLEX: action_row]
      { Gap: 2 }
      [BUTTON: view_order_btn]
        ATTR: Variant("primary"), Size("lg"), Click("navigate:/travel/orders/{{order.id|}}")
        CONTENT: "查看订单"
      [BUTTON: go_home_btn]
        ATTR: Variant("outline"), Size("lg"), Click("navigate:/travel")
        CONTENT: "回到首页"
      [IF: payment_failed]
        [BUTTON: retry_btn]
          ATTR: Variant("destructive"), Size("lg")
          CONTENT: "重新支付"
      [/IF]
