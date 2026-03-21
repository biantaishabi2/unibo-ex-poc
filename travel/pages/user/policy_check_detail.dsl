[PAGE: policy_check_detail]
  META: Entity("TravelPolicyCheck"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("超标审批详情")

  # 顶部导航
  [HEADER: page_header]
    ATTR: Back(true), Title("超标审批详情")

  # 超标状态 Badge（顶部醒目展示）
  [SECTION: status_section]
    [FLEX: status_flex]
      { Justify: "Center", PaddingY: 4 }
      [IF: check.check_result == "compliant"]
        [BADGE: status_badge_compliant]
          ATTR: Variant("success"), Size("lg")
          CONTENT: "合规"
      [/IF]
      [IF: check.check_result == "exceeded"]
        [BADGE: status_badge_exceeded]
          ATTR: Variant("warning"), Size("lg")
          CONTENT: "超标"
      [/IF]
      [IF: check.check_result == "blocked"]
        [BADGE: status_badge_blocked]
          ATTR: Variant("destructive"), Size("lg")
          CONTENT: "已拦截"
      [/IF]

  # 差标对比卡片（仅非合规场景显示）
  [SECTION: comparison_section]
    [IF: check.check_result != "compliant"]
    [CARD: comparison_card]
      [CARD_HEADER: comparison_card_header]
        [TEXT: comparison_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "差标对比"
      [CARD_CONTENT: comparison_card_content]
        [GRID: comparison_grid]
          { Columns: 2, Gap: 4 }
          # 左列：政策标准
          [STACK: policy_standard_stack]
            { Gap: 2, Align: "Center" }
            [TEXT: policy_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "差旅标准"
            [TEXT: policy_amount_display]
              ATTR: Variant("h2"), Weight("bold")
              CONTENT: "¥{{check.policy_amount|}}"
            [TEXT: policy_detail]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{check.policy.policy_name|}} · {{check.policy.cabin_class_limit|}}"
          # 右列：实际金额
          [STACK: actual_amount_stack]
            { Gap: 2, Align: "Center" }
            [TEXT: actual_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "实际金额"
            [TEXT: actual_amount_display]
              ATTR: Variant("h2"), Weight("bold"), Color("destructive")
              CONTENT: "¥{{check.actual_amount|}}"
            [TEXT: actual_detail]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{check.order.product_type|}} · {{check.order.cabin_class|}}"

        [SEPARATOR: comparison_sep]

        # 超标摘要
        [FLEX: exceed_summary_flex]
          { Justify: "SpaceAround", PaddingY: 3 }
          [STATISTIC: exceed_amount_stat]
            ATTR: Title("超标金额"), Value("¥{{check.exceed_amount|0}}"), Color("destructive")
          [STATISTIC: exceed_ratio_stat]
            ATTR: Title("超标比例"), Value("{{check.exceed_ratio|0%}}"), Color("destructive")
          [STATISTIC: strategy_stat]
            ATTR: Title("处理策略"), Value("{{check.exceed_strategy_label|}}")
    [/IF]

  # 超标原因
  [SECTION: reason_section]
    [IF: check.exceed_reason != nil]
      [CARD: reason_card]
        [CARD_HEADER: reason_card_header]
          [TEXT: reason_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "超标原因"
        [CARD_CONTENT: reason_card_content]
          [TEXT: reason_content]
            ATTR: Variant("body")
            CONTENT: "{{check.exceed_reason|}}"
    [/IF]

  # 个人支付信息（personal_pay 策略时显示）
  [SECTION: personal_pay_section]
    [IF: check.exceed_strategy == "personal_pay"]
      [CARD: personal_pay_card]
        [CARD_HEADER: personal_pay_card_header]
          [TEXT: personal_pay_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "费用分摊"
        [CARD_CONTENT: personal_pay_card_content]
          [FLEX: pay_split_flex]
            { Justify: "SpaceAround" }
            [STATISTIC: company_pay_stat]
              ATTR: Title("企业支付"), Value("¥{{check.company_pay_amount|}}"), Color("primary")
            [STATISTIC: personal_pay_stat]
              ATTR: Title("个人支付"), Value("¥{{check.personal_pay_amount|}}"), Color("warning")
    [/IF]

  # 审批链时间线（超标且策略为需审批时显示）
  [SECTION: approval_timeline_section]
    [IF: check.check_result == "exceeded"]
      [IF: check.exceed_strategy == "require_approval" && check.approval_mode != "none"]
      [CARD: timeline_card]
        [CARD_HEADER: timeline_card_header]
          [TEXT: timeline_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "审批进度"
        [CARD_CONTENT: timeline_card_content]
          [STACK: timeline_stack]
            { Gap: 0 }
            [FOR: node in check.approval_chain]
              [FLEX: timeline_node_flex]
                { Gap: 3, PaddingY: 2 }
                # 左侧时间线指示器
                [STACK: timeline_indicator_stack]
                  { Align: "Center", Gap: 0 }
                  [IF: node.status == "approved"]
                    [ICON: node_icon_approved]
                      ATTR: Name("check-circle"), Size("sm"), Color("success")
                  [/IF]
                  [IF: node.status == "rejected"]
                    [ICON: node_icon_rejected]
                      ATTR: Name("x-circle"), Size("sm"), Color("destructive")
                  [/IF]
                  [IF: node.status == "pending"]
                    [ICON: node_icon_pending]
                      ATTR: Name("clock"), Size("sm"), Color("muted")
                  [/IF]
                  [IF: node.status == "current"]
                    [ICON: node_icon_current]
                      ATTR: Name("arrow-right"), Size("sm"), Color("primary")
                  [/IF]
                # 右侧节点内容
                [STACK: timeline_node_content]
                  { Gap: 0 }
                  [FLEX: node_header_flex]
                    { Gap: 2, Align: "Center" }
                    [TEXT: node_role]
                      ATTR: Variant("body"), Weight("bold")
                      CONTENT: "{{node.role|}}"
                    [BADGE: node_status_badge]
                      CONTENT: "{{node.status_label|}}"
                  [TEXT: node_approver_name]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{node.approver_name|}}"
                  [IF: node.completed_at != nil]
                    [TEXT: node_completed_time]
                      ATTR: Variant("caption"), Color("muted")
                      CONTENT: "{{node.completed_at|}}"
                  [/IF]
                  [IF: node.comment != nil]
                    [TEXT: node_comment]
                      ATTR: Variant("caption")
                      CONTENT: "\"{{node.comment|}}\""
                  [/IF]
            [/FOR]
      [/IF]
    [/IF]

  # 关联订单信息
  [SECTION: order_info_section]
    [CARD: order_info_card]
      [CARD_HEADER: order_info_card_header]
        [TEXT: order_info_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "关联订单"
      [CARD_CONTENT: order_info_card_content]
        [GRID: order_info_grid]
          { Columns: 2, Gap: 3 }
          [FLEX: field_order_no]
            { Gap: 1 }
            [TEXT: label_order_no]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "订单号"
            [TEXT: value_order_no]
              CONTENT: "{{check.order.order_no|}}"
          [FLEX: field_product_type]
            { Gap: 1 }
            [TEXT: label_product_type]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "商品类型"
            [TEXT: value_product_type]
              CONTENT: "{{check.order.product_type_label|}}"
          [FLEX: field_traveler]
            { Gap: 1 }
            [TEXT: label_traveler]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "出行人"
            [TEXT: value_traveler]
              CONTENT: "{{check.order.traveler_name|}}"
          [FLEX: field_travel_date]
            { Gap: 1 }
            [TEXT: label_travel_date]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "出行日期"
            [TEXT: value_travel_date]
              CONTENT: "{{check.order.travel_date|}}"

  # 底部操作按钮（审批人视角）
  [SECTION: action_section]
    [IF: check.can_approve == true]
      [CONTROLBAR: action_bar]
        ATTR: Position("sticky_bottom")
        [FLEX: action_flex]
          { Justify: "SpaceAround", Width: "full", Gap: 3, PaddingX: 4 }
          [BUTTON: reject_btn]
            ATTR: Variant("destructive"), Size("lg"), Click("reject_approval"), Flex(1)
            CONTENT: "拒绝"
          [BUTTON: approve_btn]
            ATTR: Variant("primary"), Size("lg"), Click("approve_approval"), Flex(1)
            CONTENT: "通过"
    [/IF]
