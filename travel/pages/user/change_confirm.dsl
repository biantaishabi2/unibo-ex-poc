# 改签确认页
# 向导模式：3步（选择航班 → 确认差价 → 提交改签）
# 每步展示不同内容区域

[PAGE: change_confirm]
  ATTR: Title("确认改签")
  META: Entity("ChangeRequest"), Domain("Travel")

  [HEADER: change_confirm_header]
    ATTR: Back(true), Title("确认改签")

  # 步骤指示器
  [STEPPER: change_stepper]
    ATTR: Current("{{wizard.current_step|1}}")
    [STEP: step_select]
      ATTR: Index(1)
      CONTENT: "选择航班"
    [STEP: step_price]
      ATTR: Index(2)
      CONTENT: "确认差价"
    [STEP: step_submit]
      ATTR: Index(3)
      CONTENT: "提交改签"

  # 步骤内容区
  [SECTION: step_content]

    # 步骤1：原航班 vs 新航班对比
    [IF: wizard.current_step == 1]
      [STACK: step1_content]
        { Gap: 3, Padding: 3 }
        [CARD: original_flight_card]
          [CARD_HEADER: orig_card_header]
            [FLEX: orig_header_row]
              { Gap: 2, Align: "Center" }
              [BADGE: orig_label]
                ATTR: Variant("secondary")
                CONTENT: "原航班"
              [TEXT: orig_carrier_no]
                ATTR: Variant("body"), Weight("bold")
                CONTENT: "{{original.carrier_no|}}"
          [CARD_CONTENT: orig_card_content]
            [FLEX: orig_route_flex]
              { Justify: "Between", Align: "Center" }
              [STACK: orig_dep_stack]
                { Gap: 0, Align: "Center" }
                [TEXT: orig_dep_time]
                  ATTR: Variant("h2"), Weight("bold"), Color("muted")
                  CONTENT: "{{original.departure_time|}}"
                [TEXT: orig_dep_city]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{original.departure_city|}}"
              [STACK: orig_mid_stack]
                { Gap: 0, Align: "Center" }
                [TEXT: orig_date]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{original.date_label|}}"
                [ICON: plane_icon_orig]
                  ATTR: Name("plane"), Size("sm"), Color("muted")
              [STACK: orig_arr_stack]
                { Gap: 0, Align: "Center" }
                [TEXT: orig_arr_time]
                  ATTR: Variant("h2"), Weight("bold"), Color("muted")
                  CONTENT: "{{original.arrival_time|}}"
                [TEXT: orig_arr_city]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{original.arrival_city|}}"

        [ICON: change_arrow_icon]
          ATTR: Name("arrow-down"), Size("md"), Color("muted")

        [CARD: new_flight_card]
          [CARD_HEADER: new_card_header]
            [FLEX: new_header_row]
              { Gap: 2, Align: "Center" }
              [BADGE: new_label]
                ATTR: Variant("primary")
                CONTENT: "新航班"
              [TEXT: new_carrier_no]
                ATTR: Variant("body"), Weight("bold")
                CONTENT: "{{new_flight.carrier_no|}}"
              [IF: new_flight.is_policy_compliant == false]
                [BADGE: step1_exceed_badge]
                  ATTR: Variant("destructive")
                  CONTENT: "超标"
              [/IF]
          [CARD_CONTENT: new_card_content]
            [FLEX: new_route_flex]
              { Justify: "Between", Align: "Center" }
              [STACK: new_dep_stack]
                { Gap: 0, Align: "Center" }
                [TEXT: new_dep_time]
                  ATTR: Variant("h2"), Weight("bold")
                  CONTENT: "{{new_flight.departure_time|}}"
                [TEXT: new_dep_city]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{new_flight.departure_city|}}"
              [STACK: new_mid_stack]
                { Gap: 0, Align: "Center" }
                [TEXT: new_date]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{new_flight.date_label|}}"
                [ICON: plane_icon_new]
                  ATTR: Name("plane"), Size("sm")
              [STACK: new_arr_stack]
                { Gap: 0, Align: "Center" }
                [TEXT: new_arr_time]
                  ATTR: Variant("h2"), Weight("bold")
                  CONTENT: "{{new_flight.arrival_time|}}"
                [TEXT: new_arr_city]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{new_flight.arrival_city|}}"

        [CONTROL_BAR: step1_action_bar]
          ATTR: Position("sticky_bottom")
          [BUTTON: step1_next_btn]
            ATTR: Variant("primary"), Width("full"), Click("wizard_next")
            CONTENT: "下一步：确认差价"
    [/IF]

    # 步骤2：差价确认
    [IF: wizard.current_step == 2]
      [STACK: step2_content]
        { Gap: 3, Padding: 3 }
        [CARD: price_diff_card]
          [CARD_HEADER: price_diff_header]
            [TEXT: price_diff_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "费用明细"
          [CARD_CONTENT: price_diff_content]
            [STACK: price_diff_stack]
              { Gap: 3 }
              [FLEX: original_price_row]
                { Justify: "Between", Align: "Center" }
                [TEXT: original_price_label]
                  ATTR: Variant("body"), Color("muted")
                  CONTENT: "原票价"
                [TEXT: original_price_value]
                  ATTR: Variant("body")
                  CONTENT: "¥{{pricing.original_price|}}"
              [FLEX: new_price_row_2]
                { Justify: "Between", Align: "Center" }
                [TEXT: new_price_label]
                  ATTR: Variant("body"), Color("muted")
                  CONTENT: "新票价"
                [TEXT: new_price_value]
                  ATTR: Variant("body")
                  CONTENT: "¥{{pricing.new_price|}}"
              [FLEX: change_fee_row]
                { Justify: "Between", Align: "Center" }
                [TEXT: change_fee_label]
                  ATTR: Variant("body"), Color("muted")
                  CONTENT: "改签手续费"
                [TEXT: change_fee_value]
                  ATTR: Variant("body"), Color("destructive")
                  CONTENT: "¥{{pricing.change_fee|}}"
              [SEPARATOR: price_separator]
              [FLEX: total_row]
                { Justify: "Between", Align: "Center" }
                [TEXT: total_label]
                  ATTR: Variant("body"), Weight("bold")
                  CONTENT: "合计补差"
                [TEXT: total_value]
                  ATTR: Variant("h3"), Color("primary"), Weight("bold")
                  CONTENT: "¥{{pricing.total_diff|}}"
        [IF: pricing.needs_approval == true]
          [ALERT: change_approval_alert]
            ATTR: Variant("warning"), Title("需要审批")
            CONTENT: "改签后超出差旅标准，提交后将发起审批流程"
        [/IF]

        [CONTROL_BAR: step2_action_bar]
          ATTR: Position("sticky_bottom")
          [FLEX: step2_buttons]
            { Gap: 2, Width: "full" }
            [BUTTON: step2_back_btn]
              ATTR: Variant("outline"), Width("half"), Click("wizard_prev")
              CONTENT: "返回"
            [BUTTON: step2_next_btn]
              ATTR: Variant("primary"), Width("half"), Click("wizard_next")
              CONTENT: "下一步：提交改签"
    [/IF]

    # 步骤3：确认提交
    [IF: wizard.current_step == 3]
      [STACK: step3_content]
        { Gap: 3, Padding: 3 }
        [CARD: change_summary_card]
          [CARD_HEADER: summary_header]
            [TEXT: summary_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "改签信息确认"
          [CARD_CONTENT: summary_content]
            [STACK: summary_stack]
              { Gap: 2 }
              [FLEX: summary_route_row]
                { Justify: "Between" }
                [TEXT: summary_route_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "新行程"
                [TEXT: summary_route_value]
                  ATTR: Variant("body")
                  CONTENT: "{{new_flight.departure_city|}} → {{new_flight.arrival_city|}}"
              [FLEX: summary_date_row]
                { Justify: "Between" }
                [TEXT: summary_date_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "出发日期"
                [TEXT: summary_date_value]
                  ATTR: Variant("body")
                  CONTENT: "{{new_flight.date_label|}}"
              [FLEX: summary_flight_row]
                { Justify: "Between" }
                [TEXT: summary_flight_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "航班/车次"
                [TEXT: summary_flight_value]
                  ATTR: Variant("body")
                  CONTENT: "{{new_flight.carrier_no|}}"
              [FLEX: summary_total_row]
                { Justify: "Between" }
                [TEXT: summary_total_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "补差金额"
                [TEXT: summary_total_value]
                  ATTR: Variant("body"), Color("primary"), Weight("bold")
                  CONTENT: "¥{{pricing.total_diff|}}"

        [CONTROL_BAR: step3_action_bar]
          ATTR: Position("sticky_bottom")
          [FLEX: step3_buttons]
            { Gap: 2, Width: "full" }
            [BUTTON: step3_back_btn]
              ATTR: Variant("outline"), Width("half"), Click("wizard_prev")
              CONTENT: "返回"
            [BUTTON: step3_submit_btn]
              ATTR: Variant("primary"), Width("half"), Click("submit_change_request")
              CONTENT: "确认提交改签"
    [/IF]
