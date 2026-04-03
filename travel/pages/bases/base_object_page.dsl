[PAGE: base_object_page]
  ATTR: FullHeight(true), Padding(0), Variant("fit365-canvas-soft")

  [CONTAINER: object_page_shell]
    ATTR: Size("XLarge"), Variant("fit365-page-shell-compact")

    [SECTION: object_header_section]
      ATTR: Id("object_header_section"), Layout("none")
      [CARD: object_header_card]
        ATTR: Variant("fit365-shell"), ClassName("overflow-hidden")
        [CARD_CONTENT: object_header_content]
          ATTR: ClassName("p-0")

          [STACK: object_header_stack]
            ATTR: Gap(0)

            [FLEX: object_header_topbar]
              ATTR: ClassName("bg-[linear-gradient(90deg,var(--color-primary-dark-2)_0%,var(--color-primary-dark-1)_55%,var(--color-primary)_100%)] px-6 py-4 text-white"), Justify("Between"), Align("Center"), Wrap(true)
              [SECTION: breadcrumb_section]
                [BREADCRUMB: object_breadcrumb]
                  [BREADCRUMB_LIST: object_breadcrumb_list]
                    [BREADCRUMB_ITEM: object_breadcrumb_home_item]
                      [BREADCRUMB_LINK: object_breadcrumb_home]
                        ATTR: Href("#")
                        CONTENT: "业务中心"
                    [BREADCRUMB_SEPARATOR: object_breadcrumb_sep_1]
                    [BREADCRUMB_ITEM: object_breadcrumb_order_item]
                      [BREADCRUMB_LINK: object_breadcrumb_order]
                        ATTR: Href("#")
                        CONTENT: "订单管理"
                    [BREADCRUMB_SEPARATOR: object_breadcrumb_sep_2]
                    [BREADCRUMB_ITEM: object_breadcrumb_current_item]
                      [BREADCRUMB_PAGE: object_breadcrumb_current]
                        CONTENT: "{{record.code|TR-2026-0327}}"
              [FLEX: object_header_top_meta]
                ATTR: Gap(3), Align("Center"), Wrap(true)
                [BADGE: object_header_scene_badge]
                  ATTR: Variant("Secondary")
                  CONTENT: "对象详情"
                [TEXT: object_header_updated_at]
                  ATTR: Variant("Muted"), ClassName("text-white/70")
                  CONTENT: "最近更新 {{record.updated_at|2026-03-27 21:30}}"

            [GRID: object_header_body]
              ATTR: Columns(3), Gap(6), ClassName("px-6 py-6")

              [SECTION: detail_header]
                [STACK: object_profile_panel]
                  ATTR: ClassName("lg:col-span-2 space-y-5")

                  [FLEX: object_profile_row]
                    ATTR: Gap(4), Align("Center"), Wrap(true)
                    [AVATAR: object_profile_avatar]
                      ATTR: ClassName("h-16 w-16 border-4 border-[var(--color-primary-light-1)] bg-[var(--color-primary-light-2)] text-[var(--color-primary-dark-2)]")
                      [AVATAR_FALLBACK: object_profile_fallback]
                        CONTENT: "{{record.owner_initial|差}}"
                    [STACK: object_profile_meta]
                      ATTR: Gap(1)
                      [TEXT: object_profile_kicker]
                        ATTR: Variant("Muted"), ClassName("uppercase tracking-[0.28em] text-xs text-[var(--color-primary-dark-1)]")
                        CONTENT: "{{record.type|差旅订单}}"
                      [TEXT: object_profile_title]
                        ATTR: Variant("Title"), ClassName("text-3xl font-semibold text-[var(--color-text-base)]")
                        CONTENT: "{{record.title|北京客户拜访行程}}"
                      [FLEX: object_profile_badges]
                        ATTR: Gap(2), Align("Center"), Wrap(true)
                        [BADGE: object_status_badge]
                          ATTR: Variant("Default")
                          CONTENT: "{{record.status|待确认}}"
                        [BADGE: object_priority_badge]
                          ATTR: Variant("Outline")
                          CONTENT: "{{record.priority|高优先级}}"
                        [BADGE: object_channel_badge]
                          ATTR: Variant("Secondary")
                          CONTENT: "{{record.channel|企业直连}}"

                  [TEXT: object_profile_summary]
                    ATTR: Variant("Muted"), ClassName("max-w-3xl text-sm leading-6 text-[var(--color-text-secondary)]")
                    CONTENT: "{{record.summary|用于差旅履约、审批、支付与候补状态协同的统一对象页，默认展示对象头、状态流、字段分组与待办动作。}}"

                  [GRID: object_stats_section]
                    ATTR: Columns(4), Gap(4), ClassName("object-metric-grid")
                    [CARD: object_metric_budget]
                      ATTR: ClassName("border border-[var(--color-primary-light-1)] bg-[var(--color-primary-light-2)]")
                      [CARD_CONTENT: object_metric_budget_content]
                        ATTR: ClassName("px-5 py-4")
                        [STACK: object_metric_budget_stack]
                          ATTR: Gap(1)
                          [TEXT: object_metric_budget_label]
                            ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em]")
                            CONTENT: "预算"
                          [TEXT: object_metric_budget_value]
                            ATTR: Variant("Title"), ClassName("text-xl")
                            CONTENT: "{{record.budget|CNY 12,500}}"
                    [CARD: object_metric_owner]
                      ATTR: ClassName("border border-[var(--color-primary-light-1)] bg-[var(--color-primary-light-2)]")
                      [CARD_CONTENT: object_metric_owner_content]
                        ATTR: ClassName("px-5 py-4")
                        [STACK: object_metric_owner_stack]
                          ATTR: Gap(1)
                          [TEXT: object_metric_owner_label]
                            ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em]")
                            CONTENT: "负责人"
                          [TEXT: object_metric_owner_value]
                            ATTR: Variant("Title"), ClassName("text-xl")
                            CONTENT: "{{record.owner|王博}}"
                    [CARD: object_metric_deadline]
                      ATTR: ClassName("border border-[var(--color-primary-light-1)] bg-[var(--color-primary-light-2)]")
                      [CARD_CONTENT: object_metric_deadline_content]
                        ATTR: ClassName("px-5 py-4")
                        [STACK: object_metric_deadline_stack]
                          ATTR: Gap(1)
                          [TEXT: object_metric_deadline_label]
                            ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em]")
                            CONTENT: "履约时点"
                          [TEXT: object_metric_deadline_value]
                            ATTR: Variant("Title"), ClassName("text-xl")
                            CONTENT: "{{record.deadline|2026-04-02 18:00}}"
                    [CARD: object_metric_health]
                      ATTR: ClassName("border border-[var(--color-primary-light-1)] bg-[var(--color-primary-light-2)]")
                      [CARD_CONTENT: object_metric_health_content]
                        ATTR: ClassName("px-5 py-4")
                        [STACK: object_metric_health_stack]
                          ATTR: Gap(1)
                          [TEXT: object_metric_health_label]
                            ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em] text-[var(--color-primary-dark-2)]")
                            CONTENT: "进度健康度"
                          [TEXT: object_metric_health_value]
                            ATTR: Variant("Title"), ClassName("text-xl text-[var(--color-primary-dark-2)]")
                            CONTENT: "{{record.health|92%}}"

              [STACK: object_status_panel]
                ATTR: Gap(4)
                [CARD: object_status_card]
                  ATTR: Id("object_status_section"), Variant("fit365-soft")
                  [CARD_HEADER: object_status_header]
                    [CARD_TITLE: object_status_title]
                      CONTENT: "当前状态"
                    [CARD_DESCRIPTION: object_status_description]
                      CONTENT: "对象状态、审批节点与 SLA 提醒。"
                  [CARD_CONTENT: object_status_content]
                    ATTR: ClassName("space-y-4")
                    [STACK: object_status_summary]
                      ATTR: Gap(2)
                      [TEXT: object_status_text]
                        ATTR: Variant("Title"), ClassName("text-2xl")
                        CONTENT: "{{record.status|待确认}}"
                      [TEXT: object_status_hint]
                        ATTR: Variant("Muted")
                        CONTENT: "下一动作：{{record.next_action|确认报价}}"
                    [PROGRESS: object_status_progress]
                      ATTR: Value("{{record.progress|72}}")
                    [FLEX: object_status_info]
                      ATTR: Justify("Between"), Align("Center")
                      [TEXT: object_status_sla_label]
                        ATTR: Variant("Muted")
                        CONTENT: "SLA 剩余"
                      [TEXT: object_status_sla_value]
                        ATTR: ClassName("font-medium text-[var(--color-primary-dark-2)]")
                        CONTENT: "{{record.sla|05:20}}"

                [CARD: object_action_section]
                  ATTR: Variant("fit365-panel")
                  [CARD_HEADER: object_actions_header]
                    [CARD_TITLE: object_actions_title]
                      CONTENT: "待办动作"
                    [CARD_DESCRIPTION: object_actions_description]
                      CONTENT: "保持操作区固定且易扫描。"
                  [CARD_CONTENT: object_actions_content]
                    ATTR: ClassName("space-y-3")
                    [BUTTON: object_primary_action]
                      ATTR: Variant("Primary"), Size("Medium"), Click("confirm_quote"), ClassName("w-full justify-center")
                      CONTENT: "确认报价"
                    [BUTTON: object_secondary_action]
                      ATTR: Variant("Secondary"), Size("Medium"), Click("submit_workflow"), ClassName("w-full justify-center")
                      CONTENT: "提交审批"
                    [BUTTON: object_ghost_action]
                      ATTR: Variant("Outline"), Size("Medium"), Click("view_audit_log"), ClassName("w-full justify-center")
                      CONTENT: "查看操作记录"

    [SECTION: object_content_section]
      ATTR: Id("object_content_section"), Layout("none")
      [GRID: object_content_grid]
        ATTR: Id("object_main_grid"), Columns(3), Gap(6)

        [SECTION: info_section]
          [STACK: object_detail_stack]
            ATTR: ClassName("lg:col-span-2 space-y-6")

            [CARD: object_detail_group_section]
              ATTR: Variant("fit365-panel")
              [CARD_HEADER: object_detail_group_header]
                [CARD_TITLE: object_detail_group_title]
                  CONTENT: "对象信息"
                [CARD_DESCRIPTION: object_detail_group_description]
                  CONTENT: "默认提供成组字段容器，减少业务页手写结构。"
              [CARD_CONTENT: object_detail_group_content]
                [GRID: object_detail_group_grid]
                  ATTR: Columns(2), Gap(4)
                  [CARD: object_detail_field_card_1]
                    ATTR: Variant("fit365-soft")
                    [CARD_CONTENT: object_detail_field_content_1]
                      ATTR: ClassName("px-5 py-4")
                      [STACK: object_detail_field_stack_1]
                        ATTR: Gap(1)
                        [TEXT: object_detail_label_1]
                          ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em]")
                          CONTENT: "订单号"
                        [TEXT: object_detail_value_1]
                          ATTR: Variant("Title")
                          CONTENT: "{{record.code|TR-2026-0327}}"
                  [CARD: object_detail_field_card_2]
                    ATTR: Variant("fit365-soft")
                    [CARD_CONTENT: object_detail_field_content_2]
                      ATTR: ClassName("px-5 py-4")
                      [STACK: object_detail_field_stack_2]
                        ATTR: Gap(1)
                        [TEXT: object_detail_label_2]
                          ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em]")
                          CONTENT: "申请人"
                        [TEXT: object_detail_value_2]
                          ATTR: Variant("Title")
                          CONTENT: "{{record.requester|李青}}"
                  [CARD: object_detail_field_card_3]
                    ATTR: Variant("fit365-soft")
                    [CARD_CONTENT: object_detail_field_content_3]
                      ATTR: ClassName("px-5 py-4")
                      [STACK: object_detail_field_stack_3]
                        ATTR: Gap(1)
                        [TEXT: object_detail_label_3]
                          ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em]")
                          CONTENT: "出行区间"
                        [TEXT: object_detail_value_3]
                          ATTR: Variant("Title")
                          CONTENT: "{{record.trip_window|2026-04-02 ~ 2026-04-05}}"
                  [CARD: object_detail_field_card_4]
                    ATTR: Variant("fit365-soft")
                    [CARD_CONTENT: object_detail_field_content_4]
                      ATTR: ClassName("px-5 py-4")
                      [STACK: object_detail_field_stack_4]
                        ATTR: Gap(1)
                        [TEXT: object_detail_label_4]
                          ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em]")
                          CONTENT: "出行人"
                        [TEXT: object_detail_value_4]
                          ATTR: Variant("Title")
                          CONTENT: "{{record.traveler|王博 / 2人}}"

            [CARD: object_workflow_section]
              ATTR: Variant("fit365-panel")
              [CARD_HEADER: object_workflow_header]
                [CARD_TITLE: object_workflow_title]
                  CONTENT: "审批时间线"
                [CARD_DESCRIPTION: object_workflow_description]
                  CONTENT: "把工作流默认提升为对象页一等区域。"
              [CARD_CONTENT: object_workflow_content]
                [TIMELINE: object_workflow_timeline]
                  [TIMELINE_ITEM: object_workflow_item_submitted]
                    ATTR: Title("提交申请"), Description("员工提交差旅申请并生成业务对象。"), Status("completed")
                  [TIMELINE_ITEM: object_workflow_item_quote]
                    ATTR: Title("确认报价"), Description("供应商报价回填，等待运营确认。"), Status("completed")
                  [TIMELINE_ITEM: object_workflow_item_approval]
                    ATTR: Title("主管审批"), Description("当前卡在主管审批节点，需在 5 小时内处理。"), Status("in-progress")
                [TIMELINE_ITEM: object_workflow_item_fulfillment]
                  ATTR: Title("履约出票"), Description("审批通过后自动进入履约与票证回传。"), Status("pending")

        [STACK: object_side_stack]
          ATTR: Gap(6)

          [CARD: object_owner_section]
            ATTR: Variant("fit365-panel")
            [CARD_HEADER: object_owner_header]
              [CARD_TITLE: object_owner_title]
                CONTENT: "责任分工"
              [CARD_DESCRIPTION: object_owner_description]
                CONTENT: "对象默认暴露 owner / reviewer / watcher。"
            [CARD_CONTENT: object_owner_content]
              ATTR: ClassName("space-y-4")
              [FLEX: object_owner_row]
                ATTR: Justify("Between"), Align("Center")
                [TEXT: object_owner_label]
                  ATTR: Variant("Muted")
                  CONTENT: "Owner"
                [TEXT: object_owner_value]
                  CONTENT: "{{record.owner|王博}}"
              [FLEX: object_reviewer_row]
                ATTR: Justify("Between"), Align("Center")
                [TEXT: object_reviewer_label]
                  ATTR: Variant("Muted")
                  CONTENT: "Reviewer"
                [TEXT: object_reviewer_value]
                  CONTENT: "{{record.reviewer|张敏}}"
              [FLEX: object_watcher_row]
                ATTR: Justify("Between"), Align("Center")
                [TEXT: object_watcher_label]
                  ATTR: Variant("Muted")
                  CONTENT: "Watcher"
                [TEXT: object_watcher_value]
                  CONTENT: "{{record.watcher|运营共享组}}"

          [CARD: object_related_section]
            ATTR: Variant("fit365-panel")
            [CARD_HEADER: object_related_header]
              [CARD_TITLE: object_related_title]
                CONTENT: "关联履约"
              [CARD_DESCRIPTION: object_related_description]
                CONTENT: "默认预留子对象容器。"
            [CARD_CONTENT: object_related_content]
              [TABLE: object_related_table]
                [TABLE_HEADER: object_related_table_header]
                  [TABLE_ROW: object_related_table_head_row]
                    [TABLE_HEAD: object_related_head_type]
                      CONTENT: "类型"
                    [TABLE_HEAD: object_related_head_status]
                      CONTENT: "状态"
                    [TABLE_HEAD: object_related_head_ref]
                      CONTENT: "凭证"
                [TABLE_BODY: object_related_table_body]
                  [TABLE_ROW: object_related_table_row_1]
                    [TABLE_CELL: object_related_type_1]
                      CONTENT: "机票"
                    [TABLE_CELL: object_related_status_1]
                      CONTENT: "{{related.flight.status|待出票}}"
                    [TABLE_CELL: object_related_ref_1]
                      CONTENT: "{{related.flight.ref|--}}"
                  [TABLE_ROW: object_related_table_row_2]
                    [TABLE_CELL: object_related_type_2]
                      CONTENT: "酒店"
                    [TABLE_CELL: object_related_status_2]
                      CONTENT: "{{related.hotel.status|已确认}}"
                    [TABLE_CELL: object_related_ref_2]
                      CONTENT: "{{related.hotel.ref|HTL-3930}}"
