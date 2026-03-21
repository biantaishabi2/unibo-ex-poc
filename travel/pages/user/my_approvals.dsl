# 我的审批页（后端驱动）
# 使用 META+BIND 模式，展示待审批/已审批/已拒绝的审批请求列表

[PAGE: my_approvals]
  META: Entity("TravelPolicyCheck"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("我的审批")

  [HEADER: my_approvals_header]
    ATTR: Title("我的审批")

  # 标签页：按审批状态分类
  [TABS: approval_tabs]
    ATTR: Default("pending"), Bind("filter.status")
    [TABS_LIST: approval_tab_list]
      [TABS_TRIGGER: trigger_pending]
        ATTR: Value("pending")
        CONTENT: "待审批"
        [BADGE: pending_count_badge]
          ATTR: Variant("destructive")
          CONTENT: "{{stats.pending_count|}}"
      [TABS_TRIGGER: trigger_approved]
        ATTR: Value("approved")
        CONTENT: "已审批"
      [TABS_TRIGGER: trigger_rejected]
        ATTR: Value("rejected")
        CONTENT: "已拒绝"

  # 审批列表
  [STACK: approval_list]
    { Gap: 2, Padding: 3 }
    [FOR: item in rows]
      [CARD: approval_card]
        ATTR: Click("navigate:/travel/approvals/{{item.id|}}")
        [CARD_HEADER: approval_card_header]
          [FLEX: approval_header_row]
            { Justify: "Between", Align: "Center" }
            [FLEX: applicant_info_row]
              { Gap: 2, Align: "Center" }
              [AVATAR: applicant_avatar]
                ATTR: Src("{{item.applicant.avatar_url|}}"), Fallback("{{item.applicant.name_initial|}}"), Size("sm")
              [STACK: applicant_name_stack]
                { Gap: 0 }
                [TEXT: applicant_name]
                  ATTR: Variant("body"), Weight("bold")
                  CONTENT: "{{item.applicant.display_name|}}"
                [TEXT: applicant_dept]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.applicant.department_name|}}"
            [BADGE: approval_type_badge]
              ATTR: Variant("secondary")
              CONTENT: "{{item.approval_type_label|}}"
        [CARD_CONTENT: approval_card_content]
          [STACK: approval_content_stack]
            { Gap: 2 }
            [TEXT: approval_summary]
              ATTR: Variant("body")
              CONTENT: "{{item.request_summary|}}"
            [FLEX: approval_meta_row]
              { Gap: 3, Align: "Center" }
              [FLEX: approval_amount_row]
                { Gap: 1, Align: "Baseline" }
                [TEXT: approval_amount_prefix]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "金额："
                [TEXT: approval_amount]
                  ATTR: Variant("body"), Color("primary"), Weight("bold")
                  CONTENT: "¥{{item.total_amount|}}"
              [TEXT: approval_date]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{item.submitted_at_label|}}"
        [CARD_FOOTER: approval_card_footer]
          [FLEX: approval_footer_row]
            { Justify: "Between", Align: "Center" }
            [BADGE: approval_status_badge]
              ATTR: Variant("{{item.status_variant|}}")
              CONTENT: "{{item.status_label|}}"
            [IF: item.is_urgent == true]
              [BADGE: urgent_badge]
                ATTR: Variant("destructive")
                CONTENT: "加急"
            [/IF]
    [/FOR]

  # 空状态
  [IF: rows_empty]
    [EMPTY_STATE: no_approvals]
      ATTR: Title("暂无审批记录"), Description("{{filter.status == 'pending' ? '您当前没有待审批的申请' : '暂无相关审批记录'}}"), Icon("check-circle")
  [/IF]
