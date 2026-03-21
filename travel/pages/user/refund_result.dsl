# 退票结果页
# 根据退票状态（成功/处理中/被拒绝）显示不同内容

[PAGE: refund_result]
  META: Entity("TravelRefundOrder"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("退票结果")

  [HEADER: refund_result_header]
    ATTR: Back(false), Title("退票结果")

  # 状态展示区
  [STACK: result_content]
    { Gap: 4, Padding: 6, Align: "Center" }

    # 退票成功
    [IF: refund.status == "refunded"]
      [ICON: success_icon]
        ATTR: Name("check-circle"), Size("xl"), Color("success")
      [TEXT: refund_success_title]
        ATTR: Variant("h3"), Weight("bold"), Align("center")
        CONTENT: "退票成功"
      [TEXT: refund_success_amount]
        ATTR: Variant("h2"), Color("primary"), Align("center")
        CONTENT: "退款 ¥{{refund.refund_amount|}}"
      [TEXT: refund_success_desc]
        ATTR: Variant("body"), Color("muted"), Align("center")
        CONTENT: "退款将在3-5个工作日内原路返回"
    [/IF]

    # 退票处理中
    [IF: refund.status == "pending"]
      [ICON: pending_icon]
        ATTR: Name("clock"), Size("xl"), Color("warning")
      [TEXT: refund_pending_title]
        ATTR: Variant("h3"), Weight("bold"), Align("center")
        CONTENT: "退票处理中"
      [TEXT: refund_pending_desc]
        ATTR: Variant("body"), Color("muted"), Align("center")
        CONTENT: "您的退票申请已提交，正在处理中，请耐心等待"
    [/IF]

    # 退票待审批
    [IF: refund.status == "approving"]
      [ICON: approving_icon]
        ATTR: Name("user-check"), Size("xl"), Color("info")
      [TEXT: refund_approving_title]
        ATTR: Variant("h3"), Weight("bold"), Align("center")
        CONTENT: "等待审批"
      [TEXT: refund_approving_desc]
        ATTR: Variant("body"), Color("muted"), Align("center")
        CONTENT: "退票申请需要审批，已通知审批人{{refund.approver_name|}}"
    [/IF]

    # 退票被拒绝
    [IF: refund.status == "rejected"]
      [ICON: error_icon]
        ATTR: Name("x-circle"), Size("xl"), Color("destructive")
      [TEXT: refund_rejected_title]
        ATTR: Variant("h3"), Weight("bold"), Align("center")
        CONTENT: "退票被拒绝"
      [TEXT: refund_rejected_reason]
        ATTR: Variant("body"), Color("muted"), Align("center")
        CONTENT: "原因：{{refund.reject_reason|}}"
    [/IF]

  # 退票订单详情
  [CARD: refund_detail_card]
    [CARD_HEADER: refund_detail_header]
      [TEXT: refund_detail_title]
        ATTR: Variant("h4"), Weight("bold")
        CONTENT: "退票详情"
    [CARD_CONTENT: refund_detail_content]
      [STACK: refund_detail_stack]
        { Gap: 2 }
        [FLEX: detail_order_no_row]
          { Justify: "Between" }
          [TEXT: detail_order_no_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "原订单号"
          [TEXT: detail_order_no_value]
            ATTR: Variant("caption")
            CONTENT: "{{refund.original_order_no|}}"
        [FLEX: detail_refund_no_row]
          { Justify: "Between" }
          [TEXT: detail_refund_no_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "退票单号"
          [TEXT: detail_refund_no_value]
            ATTR: Variant("caption")
            CONTENT: "{{refund.refund_no|}}"
        [FLEX: detail_route_row]
          { Justify: "Between" }
          [TEXT: detail_route_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "退票行程"
          [TEXT: detail_route_value]
            ATTR: Variant("body")
            CONTENT: "{{refund.route_summary|}}"
        [FLEX: detail_apply_time_row]
          { Justify: "Between" }
          [TEXT: detail_apply_time_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "申请时间"
          [TEXT: detail_apply_time_value]
            ATTR: Variant("caption")
            CONTENT: "{{refund.applied_at|}}"
        [FLEX: detail_paid_amount_row]
          { Justify: "Between" }
          [TEXT: detail_paid_amount_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "原支付金额"
          [TEXT: detail_paid_amount_value]
            ATTR: Variant("body")
            CONTENT: "¥{{refund.original_amount|}}"
        [FLEX: detail_fee_row]
          { Justify: "Between" }
          [TEXT: detail_fee_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "退票手续费"
          [TEXT: detail_fee_value]
            ATTR: Variant("body"), Color("destructive")
            CONTENT: "¥{{refund.fee|}}"
        [FLEX: detail_refund_amount_row]
          { Justify: "Between" }
          [TEXT: detail_refund_amount_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "实际退款"
          [TEXT: detail_refund_amount_value]
            ATTR: Variant("body"), Color("primary"), Weight("bold")
            CONTENT: "¥{{refund.refund_amount|}}"
        [IF: refund.reason != null]
          [FLEX: detail_reason_row]
            { Justify: "Between" }
            [TEXT: detail_reason_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "退票原因"
            [TEXT: detail_reason_value]
              ATTR: Variant("caption")
              CONTENT: "{{refund.reason_label|}}"
        [/IF]

  # 底部按钮
  [STACK: result_actions]
    { Gap: 2, Padding: 3 }
    [BUTTON: back_to_orders]
      ATTR: Variant("primary"), Width("full"), Click("navigate:/travel/orders")
      CONTENT: "返回订单列表"
    [IF: refund.status == "rejected"]
      [BUTTON: retry_refund_btn]
        ATTR: Variant("outline"), Width("full"), Click("navigate:/travel/refund/apply/{{refund.original_order_id|}}")
        CONTENT: "重新申请退票"
    [/IF]
