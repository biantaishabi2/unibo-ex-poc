[PAGE: order_list]
  META: Entity("TravelOrder"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("我的行程")

  [SECTION: filter_section]
    [TABS: product_type_tabs]
      ATTR: Default("all")
      [TABS_LIST: type_tab_list]
        [TABS_TRIGGER: trigger_all]
          ATTR: Value("all")
          CONTENT: "全部"
        [TABS_TRIGGER: trigger_flight]
          ATTR: Value("flight")
          CONTENT: "机票"
        [TABS_TRIGGER: trigger_hotel]
          ATTR: Value("hotel")
          CONTENT: "酒店"
        [TABS_TRIGGER: trigger_train]
          ATTR: Value("train")
          CONTENT: "火车"

  [SECTION: order_list_section]
    [STACK: orders_stack]
      { Gap: 2 }
      [FOR: item in orders]
        [CARD: order_card]
          ATTR: Click("navigate:/travel/orders/{{item.id|}}")
          [CARD_HEADER: order_header]
            [FLEX: header_row]
              { Justify: "Between", Align: "Center" }
              [FLEX: type_icon_row]
                { Gap: 2, Align: "Center" }
                [BADGE: type_badge]
                  ATTR: Variant("secondary")
                  CONTENT: "{{item.product_type|}}"
              [BADGE: status_badge]
                ATTR: Variant("outline")
                CONTENT: "{{item.status|}}"
          [CARD_CONTENT: order_content]
            [STACK: content_stack]
              { Gap: 2 }
              [TEXT: order_summary]
                ATTR: Variant("body"), Weight("bold")
                CONTENT: "{{item.summary|}}"
              [TEXT: order_no]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{item.order_no|}}"
              [FLEX: tag_row]
                { Gap: 1 }
                [BADGE: enterprise_pay_badge]
                  ATTR: Variant("secondary")
                  CONTENT: "企业支付"
                [IF: item.has_travel_purpose]
                  [BADGE: purpose_badge]
                    ATTR: Variant("secondary")
                    CONTENT: "{{item.travel_purpose|}}"
                [/IF]
                [IF: item.has_change]
                  [BADGE: refund_badge]
                    ATTR: Variant("destructive")
                    CONTENT: "退"
                [/IF]
          [CARD_FOOTER: order_footer]
            [FLEX: footer_row]
              { Justify: "Between", Align: "Center" }
              [TEXT: total_amount]
                ATTR: Variant("h3")
                CONTENT: "{{item.total_amount|}}"
      [/FOR]

  [SECTION: empty_section]
    [IF: orders_empty]
      [EMPTY_STATE: no_orders]
        ATTR: Title("暂无行程订单"), Description("您还没有预订任何行程"), Icon("plane")
    [/IF]
