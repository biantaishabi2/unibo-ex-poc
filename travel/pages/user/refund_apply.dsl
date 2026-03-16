# 退票申请页
# 表单页：展示原订单信息 + 退票原因选择 + 退款金额预估

[PAGE: refund_apply]
  ATTR: Title("退票申请")
  META: Entity("RefundRequest"), Domain("Travel")

  [HEADER: refund_apply_header]
    ATTR: Back(true), Title("退票申请")

  # 原订单摘要
  [CARD: refund_order_summary]
    [CARD_HEADER: order_summary_header]
      [FLEX: order_summary_header_row]
        { Gap: 2, Align: "Center", Justify: "Between" }
        [TEXT: order_summary_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "订单信息"
        [BADGE: order_type_badge]
          ATTR: Variant("secondary")
          CONTENT: "{{order.product_type_label|}}"
    [CARD_CONTENT: order_summary_content]
      [STACK: order_summary_stack]
        { Gap: 2 }
        [FLEX: order_route_row]
          { Justify: "Between" }
          [TEXT: order_route_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "行程"
          [TEXT: order_route_value]
            ATTR: Variant("body"), Weight("bold")
            CONTENT: "{{order.summary|}}"
        [FLEX: order_date_row]
          { Justify: "Between" }
          [TEXT: order_date_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "出行日期"
          [TEXT: order_date_value]
            ATTR: Variant("body")
            CONTENT: "{{order.travel_date_label|}}"
        [FLEX: order_no_row]
          { Justify: "Between" }
          [TEXT: order_no_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "订单号"
          [TEXT: order_no_value]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "{{order.order_no|}}"
        [FLEX: order_amount_row]
          { Justify: "Between" }
          [TEXT: order_amount_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "支付金额"
          [TEXT: order_amount_value]
            ATTR: Variant("body"), Weight("bold")
            CONTENT: "¥{{order.paid_amount|}}"

  # 退票表单
  [CARD: refund_form_card]
    [CARD_HEADER: refund_form_header]
      [TEXT: refund_form_title]
        ATTR: Variant("h4"), Weight("bold")
        CONTENT: "退票信息"
    [CARD_CONTENT: refund_form_content]
      [FORM: refund_form]
        ATTR: Name("refund_form"), Action("submit_refund")

        # 退票原因
        [SELECT: refund_reason]
          ATTR: Label("退票原因"), Name("reason"), Required(true), Placeholder("请选择退票原因")
          [OPTION: reason_plan_change] CONTENT: "行程变更"
          [OPTION: reason_business_cancel] CONTENT: "出差取消"
          [OPTION: reason_force_majeure] CONTENT: "不可抗力（自然灾害/疫情）"
          [OPTION: reason_visa_issue] CONTENT: "签证/手续问题"
          [OPTION: reason_personal] CONTENT: "个人原因"
          [OPTION: reason_other] CONTENT: "其他"

        # 退票手续费（只读展示）
        [FLEX: refund_fee_row]
          { Justify: "Between", Align: "Center", PaddingY: 2 }
          [TEXT: refund_fee_label]
            ATTR: Variant("body"), Color("muted")
            CONTENT: "预计手续费"
          [TEXT: refund_fee_display]
            ATTR: Variant("body"), Color("destructive"), Weight("bold")
            CONTENT: "¥{{refund_estimate.fee|}}"

        # 预计退款金额（只读展示）
        [FLEX: refund_amount_row]
          { Justify: "Between", Align: "Center", PaddingY: 2 }
          [TEXT: refund_amount_label]
            ATTR: Variant("body"), Color("muted")
            CONTENT: "预计退款金额"
          [TEXT: refund_amount_display]
            ATTR: Variant("h3"), Color("primary"), Weight("bold")
            CONTENT: "¥{{refund_estimate.amount|}}"

        [SEPARATOR: refund_form_sep]

        # 备注（可选）
        [TEXTAREA: refund_note]
          ATTR: Label("补充说明（可选）"), Name("note"), Placeholder("如有特殊情况请说明，审批时将作参考"), MaxLength(200), Rows(3)

  # 退款说明提示
  [ALERT: refund_notice_alert]
    ATTR: Variant("info"), Title("退款说明")
    CONTENT: "退款将原路退回至企业账户，预计3-5个工作日到账"

  [CONTROL_BAR: refund_submit_bar]
    ATTR: Position("sticky_bottom")
    [FLEX: submit_bar_content]
      { Justify: "Between", Align: "Center", Width: "full" }
      [FLEX: refund_total_display]
        { Gap: 1, Align: "Baseline" }
        [TEXT: submit_refund_amount_label]
          ATTR: Variant("caption"), Color("muted")
          CONTENT: "退款："
        [TEXT: submit_refund_amount]
          ATTR: Variant("h3"), Color("primary")
          CONTENT: "¥{{refund_estimate.amount|}}"
      [BUTTON: submit_refund_btn]
        ATTR: Variant("primary"), Click("submit_refund_form")
        CONTENT: "提交退票申请"
