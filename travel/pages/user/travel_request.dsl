# 出差申请页
# 向导模式：4步（基本信息 → 行程安排 → 预算 → 确认提交）

[PAGE: travel_request]
  ATTR: Title("出差申请")

  [HEADER: travel_request_header]
    ATTR: Back(true), Title("出差申请")

  # 步骤指示器
  [STEPPER: travel_request_stepper]
    ATTR: Current("{{wizard.current_step|1}}")
    [STEP: step_basic]
      ATTR: Index(1)
      CONTENT: "基本信息"
    [STEP: step_itinerary]
      ATTR: Index(2)
      CONTENT: "行程安排"
    [STEP: step_budget]
      ATTR: Index(3)
      CONTENT: "预算"
    [STEP: step_confirm]
      ATTR: Index(4)
      CONTENT: "提交"

  # 步骤内容
  [SECTION: travel_request_step_content]

    # 步骤1：基本信息
    [IF: wizard.current_step == 1]
      [STACK: step1_basic_content]
        { Gap: 3, Padding: 3 }
        [CARD: basic_info_card]
          [CARD_CONTENT: basic_info_content]
            [FORM: basic_info_form]
              ATTR: Name("basic_info_form")
              [TEXTAREA: trip_purpose]
                ATTR: Label("出差事由"), Name("purpose"), Required(true), Placeholder("请描述出差目的和主要工作内容"), Rows(3)
              [INPUT: trip_start_date]
                ATTR: Label("出发日期"), Name("start_date"), Required("true"), Type("date")
              [INPUT: trip_end_date]
                ATTR: Label("返回日期"), Name("end_date"), Required("true"), Type("date")
              [SELECT: trip_destination]
                ATTR: Label("目的城市"), Name("destination_city"), Required(true), Placeholder("请选择目的城市")
              [INPUT: trip_destination_detail]
                ATTR: Label("具体地点"), Name("destination_detail"), Placeholder("如：北京市朝阳区XX大厦（可选）")
              [SELECT: trip_type]
                ATTR: Label("出差类型"), Name("trip_type"), Required(true)
                CONTENT: "国内出差:domestic,境外出差:overseas"
              [SELECT: trip_companion_count]
                ATTR: Label("随行人数"), Name("companion_count")
                CONTENT: "独自出差:alone,2人:two,3人:three,4人及以上:more"

        [CONTROL_BAR: step1_basic_action_bar]
          ATTR: Position("sticky_bottom")
          [BUTTON: step1_basic_next_btn]
            ATTR: Variant("primary"), Width("full"), Click("wizard_next")
            CONTENT: "下一步：行程安排"
    [/IF]

    # 步骤2：行程安排（交通+住宿）
    [IF: wizard.current_step == 2]
      [STACK: step2_itinerary_content]
        { Gap: 3, Padding: 3 }

        [TEXT: itinerary_tip]
          ATTR: Variant("caption"), Color("muted")
          CONTENT: "请添加每段行程的交通和住宿安排"

        # 已添加的行程段
        [FOR: seg in itinerary.segments]
          [CARD: trip_segment_card]
            [CARD_HEADER: seg_header]
              [FLEX: seg_header_row]
                { Justify: "Between", Align: "Center" }
                [TEXT: seg_title]
                  ATTR: Variant("body"), Weight("bold")
                  CONTENT: "行程段 {{seg.index|}}"
                [BUTTON: delete_seg_btn]
                  ATTR: Variant("ghost"), Size("sm"), Icon("trash-2"), Click("delete_segment"), Params("{{seg.id|}}")
                  CONTENT: "删除"
            [CARD_CONTENT: seg_content]
              [STACK: seg_content_stack]
                { Gap: 2 }
                # 交通
                [FLEX: seg_transport_row]
                  { Gap: 2, Align: "Center" }
                  [ICON: transport_icon]
                    ATTR: Name("{{seg.transport_icon|}}"), Size("sm")
                  [TEXT: seg_transport_summary]
                    ATTR: Variant("body")
                    CONTENT: "{{seg.transport_summary|}}"
                  [BADGE: seg_transport_type_badge]
                    ATTR: Variant("secondary")
                    CONTENT: "{{seg.transport_type_label|}}"
                # 住宿
                [IF: seg.has_hotel == true]
                  [FLEX: seg_hotel_row]
                    { Gap: 2, Align: "Center" }
                    [ICON: hotel_icon]
                      ATTR: Name("building"), Size("sm")
                    [TEXT: seg_hotel_summary]
                      ATTR: Variant("body")
                      CONTENT: "{{seg.hotel_summary|}}"
                    [BADGE: seg_hotel_nights_badge]
                      ATTR: Variant("secondary")
                      CONTENT: "{{seg.hotel_nights|}}晚"
                [/IF]
        [/FOR]

        # 添加行程段按钮
        [BUTTON: add_segment_btn]
          ATTR: Variant("outline"), Width("full"), Icon("plus"), Click("add_itinerary_segment")
          CONTENT: "添加行程段"

        [CONTROL_BAR: step2_itinerary_action_bar]
          ATTR: Position("sticky_bottom")
          [FLEX: step2_buttons]
            { Gap: 2, Width: "full" }
            [BUTTON: step2_back_btn]
              ATTR: Variant("outline"), Width("half"), Click("wizard_prev")
              CONTENT: "返回"
            [BUTTON: step2_next_btn]
              ATTR: Variant("primary"), Width("half"), Click("wizard_next")
              CONTENT: "下一步：预算"
    [/IF]

    # 步骤3：预算预估
    [IF: wizard.current_step == 3]
      [STACK: step3_budget_content]
        { Gap: 3, Padding: 3 }
        [CARD: budget_card]
          [CARD_HEADER: budget_header]
            [TEXT: budget_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "预算预估"
          [CARD_CONTENT: budget_content]
            [STACK: budget_stack]
              { Gap: 2 }
              [FLEX: budget_transport_row]
                { Justify: "Between" }
                [TEXT: budget_transport_label]
                  ATTR: Variant("body"), Color("muted")
                  CONTENT: "交通费用"
                [TEXT: budget_transport_value]
                  ATTR: Variant("body")
                  CONTENT: "¥{{budget.transport_estimate|}}"
              [FLEX: budget_hotel_row]
                { Justify: "Between" }
                [TEXT: budget_hotel_label]
                  ATTR: Variant("body"), Color("muted")
                  CONTENT: "住宿费用"
                [TEXT: budget_hotel_value]
                  ATTR: Variant("body")
                  CONTENT: "¥{{budget.hotel_estimate|}}"
              [FLEX: budget_meal_row]
                { Justify: "Between" }
                [TEXT: budget_meal_label]
                  ATTR: Variant("body"), Color("muted")
                  CONTENT: "餐饮补贴"
                [TEXT: budget_meal_value]
                  ATTR: Variant("body")
                  CONTENT: "¥{{budget.meal_allowance|}}"
              [FLEX: budget_other_row]
                { Justify: "Between" }
                [TEXT: budget_other_label]
                  ATTR: Variant("body"), Color("muted")
                  CONTENT: "其他费用"
                [INPUT: budget_other_input]
                  ATTR: Name("other_budget"), Placeholder("0"), Type("number")
              [SEPARATOR: budget_sep]
              [FLEX: budget_total_row]
                { Justify: "Between" }
                [TEXT: budget_total_label]
                  ATTR: Variant("body"), Weight("bold")
                  CONTENT: "预算合计"
                [TEXT: budget_total_value]
                  ATTR: Variant("h3"), Color("primary"), Weight("bold")
                  CONTENT: "¥{{budget.total_estimate|}}"

        # 差标提示
        [IF: budget.policy_exceeded == true]
          [ALERT: budget_policy_alert]
            ATTR: Variant("warning"), Title("超出差旅标准")
            CONTENT: "预算超出您的差旅标准 ¥{{budget.exceed_amount|}}，提交后需要上级审批"
        [/IF]

        [CARD: allowance_card]
          [CARD_HEADER: allowance_header]
            [TEXT: allowance_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "适用差标"
          [CARD_CONTENT: allowance_content]
            [STACK: allowance_stack]
              { Gap: 2 }
              [FLEX: allowance_transport_row]
                { Justify: "Between" }
                [TEXT: allowance_transport_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "交通差标"
                [TEXT: allowance_transport_value]
                  ATTR: Variant("caption")
                  CONTENT: "{{policy.transport_standard|}}"
              [FLEX: allowance_hotel_row]
                { Justify: "Between" }
                [TEXT: allowance_hotel_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "住宿差标"
                [TEXT: allowance_hotel_value]
                  ATTR: Variant("caption")
                  CONTENT: "¥{{policy.hotel_limit_per_night|}}/晚"
              [FLEX: allowance_meal_row]
                { Justify: "Between" }
                [TEXT: allowance_meal_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "餐补标准"
                [TEXT: allowance_meal_value]
                  ATTR: Variant("caption")
                  CONTENT: "¥{{policy.meal_allowance_per_day|}}/天"

        [CONTROL_BAR: step3_budget_action_bar]
          ATTR: Position("sticky_bottom")
          [FLEX: step3_buttons]
            { Gap: 2, Width: "full" }
            [BUTTON: step3_back_btn]
              ATTR: Variant("outline"), Width("half"), Click("wizard_prev")
              CONTENT: "返回"
            [BUTTON: step3_next_btn]
              ATTR: Variant("primary"), Width("half"), Click("wizard_next")
              CONTENT: "下一步：确认提交"
    [/IF]

    # 步骤4：确认并提交
    [IF: wizard.current_step == 4]
      [STACK: step4_confirm_content]
        { Gap: 3, Padding: 3 }
        [CARD: confirm_summary_card]
          [CARD_HEADER: confirm_summary_header]
            [TEXT: confirm_summary_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "申请信息确认"
          [CARD_CONTENT: confirm_summary_content]
            [STACK: confirm_summary_stack]
              { Gap: 3 }
              # 基本信息摘要
              [FLEX: confirm_purpose_row]
                { Justify: "Between" }
                [TEXT: confirm_purpose_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "出差事由"
                [TEXT: confirm_purpose_value]
                  ATTR: Variant("body")
                  CONTENT: "{{form.purpose|}}"
              [FLEX: confirm_date_row]
                { Justify: "Between" }
                [TEXT: confirm_date_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "出差日期"
                [TEXT: confirm_date_value]
                  ATTR: Variant("body")
                  CONTENT: "{{form.date_range_label|}}"
              [FLEX: confirm_destination_row]
                { Justify: "Between" }
                [TEXT: confirm_destination_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "目的城市"
                [TEXT: confirm_destination_value]
                  ATTR: Variant("body")
                  CONTENT: "{{form.destination_city|}}"
              [SEPARATOR: confirm_sep1]
              [FLEX: confirm_segments_row]
                { Justify: "Between" }
                [TEXT: confirm_segments_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "行程段数"
                [TEXT: confirm_segments_value]
                  ATTR: Variant("body")
                  CONTENT: "{{itinerary.segment_count|}}段"
              [SEPARATOR: confirm_sep2]
              [FLEX: confirm_budget_row]
                { Justify: "Between" }
                [TEXT: confirm_budget_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "预算合计"
                [TEXT: confirm_budget_value]
                  ATTR: Variant("h3"), Color("primary"), Weight("bold")
                  CONTENT: "¥{{budget.total_estimate|}}"
              [IF: budget.policy_exceeded == true]
                [BADGE: confirm_exceed_badge]
                  ATTR: Variant("destructive")
                  CONTENT: "超出差标，需审批"
              [/IF]

        [CONTROL_BAR: step4_confirm_action_bar]
          ATTR: Position("sticky_bottom")
          [FLEX: step4_buttons]
            { Gap: 2, Width: "full" }
            [BUTTON: step4_back_btn]
              ATTR: Variant("outline"), Width("half"), Click("wizard_prev")
              CONTENT: "返回"
            [BUTTON: step4_submit_btn]
              ATTR: Variant("primary"), Width("half"), Click("submit_travel_request")
              CONTENT: "提交出差申请"
    [/IF]
