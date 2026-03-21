# 审批操作详情页
# 展示申请人信息、申请详情（类型相关）、差标检查、审批链时间轴，支持通过/拒绝操作

[PAGE: approval_detail]
  META: Entity("TravelPolicyCheck"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("审批详情")

  [HEADER: approval_detail_header]
    ATTR: Back(true), Title("审批详情")

  # 申请人信息
  [CARD: applicant_card]
    [CARD_CONTENT: applicant_card_content]
      [FLEX: applicant_flex]
        { Gap: 4, Align: "Center", PaddingY: 2 }
        [AVATAR: detail_applicant_avatar]
          ATTR: Src("{{approval.applicant.avatar_url|}}"), Fallback("{{approval.applicant.name_initial|}}"), Size("lg")
        [STACK: applicant_detail_stack]
          { Gap: 1 }
          [FLEX: applicant_name_row]
            { Gap: 2, Align: "Center" }
            [TEXT: detail_applicant_name]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "{{approval.applicant.display_name|}}"
            [BADGE: detail_approval_type]
              ATTR: Variant("secondary")
              CONTENT: "{{approval.approval_type_label|}}"
          [TEXT: detail_applicant_dept]
            ATTR: Variant("body"), Color("muted")
            CONTENT: "{{approval.applicant.department_name|}} · {{approval.applicant.job_level_label|}}"
          [TEXT: detail_submit_time]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "提交于 {{approval.submitted_at|}}"

  # 申请内容详情（根据类型展示不同内容）
  [CARD: request_card]
    [CARD_HEADER: request_card_header]
      [TEXT: request_card_title]
        ATTR: Variant("h4"), Weight("bold")
        CONTENT: "申请详情"
    [CARD_CONTENT: request_card_content]
      # 出差申请
      [IF: approval.approval_type == "travel_request"]
        [STACK: travel_request_detail]
          { Gap: 2 }
          [FLEX: tr_purpose_row]
            { Justify: "Between" }
            [TEXT: tr_purpose_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "出差事由"
            [TEXT: tr_purpose_value]
              ATTR: Variant("body")
              CONTENT: "{{approval.request.purpose|}}"
          [FLEX: tr_date_row]
            { Justify: "Between" }
            [TEXT: tr_date_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "出差日期"
            [TEXT: tr_date_value]
              ATTR: Variant("body")
              CONTENT: "{{approval.request.date_range_label|}}"
          [FLEX: tr_destination_row]
            { Justify: "Between" }
            [TEXT: tr_destination_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "目的城市"
            [TEXT: tr_destination_value]
              ATTR: Variant("body")
              CONTENT: "{{approval.request.destination_city|}}"
          [FLEX: tr_budget_row]
            { Justify: "Between" }
            [TEXT: tr_budget_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "预计费用"
            [TEXT: tr_budget_value]
              ATTR: Variant("body"), Color("primary"), Weight("bold")
              CONTENT: "¥{{approval.request.total_budget|}}"
      [/IF]

      # 改签申请
      [IF: approval.approval_type == "change_request"]
        [STACK: change_request_detail]
          { Gap: 2 }
          [FLEX: cr_original_row]
            { Justify: "Between" }
            [TEXT: cr_original_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "原行程"
            [TEXT: cr_original_value]
              ATTR: Variant("body"), Style("line-through"), Color("muted")
              CONTENT: "{{approval.request.original_summary|}}"
          [FLEX: cr_new_row]
            { Justify: "Between" }
            [TEXT: cr_new_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "新行程"
            [TEXT: cr_new_value]
              ATTR: Variant("body")
              CONTENT: "{{approval.request.new_summary|}}"
          [FLEX: cr_diff_row]
            { Justify: "Between" }
            [TEXT: cr_diff_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "补差金额"
            [TEXT: cr_diff_value]
              ATTR: Variant("body"), Color("primary"), Weight("bold")
              CONTENT: "¥{{approval.request.price_diff|}}"
      [/IF]

      # 退票申请
      [IF: approval.approval_type == "refund_request"]
        [STACK: refund_request_detail]
          { Gap: 2 }
          [FLEX: rr_order_row]
            { Justify: "Between" }
            [TEXT: rr_order_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "退票行程"
            [TEXT: rr_order_value]
              ATTR: Variant("body")
              CONTENT: "{{approval.request.route_summary|}}"
          [FLEX: rr_reason_row]
            { Justify: "Between" }
            [TEXT: rr_reason_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "退票原因"
            [TEXT: rr_reason_value]
              ATTR: Variant("body")
              CONTENT: "{{approval.request.reason_label|}}"
          [FLEX: rr_refund_row]
            { Justify: "Between" }
            [TEXT: rr_refund_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "退款金额"
            [TEXT: rr_refund_value]
              ATTR: Variant("body"), Color("primary"), Weight("bold")
              CONTENT: "¥{{approval.request.refund_amount|}}"
      [/IF]

  # 差标检查（超标时显示）
  [IF: approval.has_policy_violation == true]
    [CARD: policy_card]
      [CARD_HEADER: policy_card_header]
        [FLEX: policy_header_row]
          { Gap: 2, Align: "Center" }
          [ICON: policy_warning_icon]
            ATTR: Name("alert-triangle"), Size("sm"), Color("warning")
          [TEXT: policy_card_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "超标详情"
      [CARD_CONTENT: policy_card_content]
        [STACK: policy_violations_stack]
          { Gap: 2 }
          [FOR: violation in approval.policy_violations]
            [FLEX: violation_row]
              { Gap: 2, Align: "Center" }
              [BADGE: violation_type_badge]
                ATTR: Variant("destructive")
                CONTENT: "{{violation.type_label|}}"
              [TEXT: violation_desc]
                ATTR: Variant("caption")
                CONTENT: "{{violation.description|}}"
          [/FOR]
  [/IF]

  # 审批链时间轴
  [CARD: approval_history_card]
    [CARD_HEADER: history_card_header]
      [TEXT: history_card_title]
        ATTR: Variant("h4"), Weight("bold")
        CONTENT: "审批流程"
    [CARD_CONTENT: history_card_content]
      [STACK: approval_timeline]
        { Gap: 0 }
        [FOR: step in approval.approval_chain]
          [FLEX: timeline_step_row]
            { Gap: 3, PaddingY: 2 }
            [STACK: timeline_indicator]
              { Gap: 0, Align: "Center", Width: "auto" }
              [ICON: timeline_step_icon]
                ATTR: Name("{{step.icon|}}"), Size("sm"), Color("{{step.color|}}")
              [IF: step.is_last == false]
                [SEPARATOR: timeline_connector]
                  ATTR: Orientation("vertical"), Height("full")
              [/IF]
            [STACK: timeline_content]
              { Gap: 1 }
              [FLEX: timeline_approver_row]
                { Gap: 2, Align: "Center" }
                [AVATAR: timeline_approver_avatar]
                  ATTR: Src("{{step.approver.avatar_url|}}"), Fallback("{{step.approver.name_initial|}}"), Size("xs")
                [TEXT: timeline_approver_name]
                  ATTR: Variant("body"), Weight("bold")
                  CONTENT: "{{step.approver.display_name|}}"
                [BADGE: timeline_step_status]
                  ATTR: Variant("{{step.status_variant|}}")
                  CONTENT: "{{step.status_label|}}"
              [TEXT: timeline_step_role]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{step.role_label|}}"
              [IF: step.comment != null]
                [TEXT: timeline_step_comment]
                  ATTR: Variant("caption"), Color("muted"), Style("italic")
                  CONTENT: "\"{{step.comment|}}\""
              [/IF]
              [IF: step.acted_at != null]
                [TEXT: timeline_step_time]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{step.acted_at|}}"
              [/IF]
        [/FOR]

  # 底部操作栏（仅当前审批人可操作且状态为待审批时显示）
  [IF: approval.current_user_can_act == true]
    [CONTROL_BAR: approval_action_bar]
      ATTR: Position("sticky_bottom")
      [FLEX: action_bar_content]
        { Gap: 2, Width: "full" }
        # 拒绝按钮
        [BUTTON: reject_btn]
          ATTR: Variant("outline"), Width("half"), Icon("x"), Click("show_reject_dialog")
          CONTENT: "拒绝"
        # 通过按钮
        [BUTTON: approve_btn]
          ATTR: Variant("primary"), Width("half"), Icon("check"), Click("approve_request")
          CONTENT: "通过"

      # 拒绝对话框（inline）
      [DIALOG: reject_dialog]
        ATTR: Trigger("reject_btn"), Title("拒绝原因")
        [DIALOG_CONTENT: reject_dialog_content]
          [TEXTAREA: reject_comment]
            ATTR: Label("请填写拒绝原因"), Name("reject_comment"), Required(true), Placeholder("请说明拒绝原因，便于申请人改进"), Rows(3)
        [DIALOG_FOOTER: reject_dialog_footer]
          [BUTTON: cancel_reject_btn]
            ATTR: Variant("outline"), Click("close_reject_dialog")
            CONTENT: "取消"
          [BUTTON: confirm_reject_btn]
            ATTR: Variant("destructive"), Click("reject_request")
            CONTENT: "确认拒绝"
  [/IF]
