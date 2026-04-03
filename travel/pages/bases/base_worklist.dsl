[PAGE: base_worklist]
  ATTR: Title("工作列表"), FullHeight(true), Padding(0), Variant("fit365-canvas")
  [SECTION: queue_filters]
    [STACK: queue_filters_stack]
      { Gap: 4 }
      [CARD: queue_header_card]
        ATTR: Variant("fit365-shell"), ClassName("overflow-hidden")
        [CARD_CONTENT: queue_header_content]
          [STACK: queue_header_stack]
            ATTR: Gap(0)
            [FLEX: queue_header]
              ATTR: ClassName("bg-[linear-gradient(90deg,var(--color-primary-dark-2)_0%,var(--color-primary-dark-1)_55%,var(--color-primary)_100%)] px-6 py-4 text-white"), Justify("Between"), Align("Center"), Wrap(true), Gap(3)
              [STACK: queue_header_meta]
                ATTR: Gap(2)
                [TEXT: page_title]
                  ATTR: Variant("title")
                  CONTENT: "{{page_title|工作列表}}"
                [TEXT: queue_header_hint]
                  ATTR: Variant("caption")
                  CONTENT: "{{queue_hint|把队列、筛选和主从详情组织成统一工作台}}"
              [FLEX: bulk_actions]
                ATTR: Gap(2), Wrap(true)
                [BUTTON: bulk_approve]
                  ATTR: Variant("primary"), Click("bulk_approve")
                  CONTENT: "批量通过"
                [BUTTON: bulk_reject]
                  ATTR: Variant("secondary"), Click("bulk_reject")
                  CONTENT: "批量驳回"
            [FLEX: queue_summary_row]
              ATTR: ClassName("px-6 py-5"), Gap(2), Wrap(true), Align("Center")
              [BADGE: queue_status_badge]
                ATTR: Variant("secondary")
                CONTENT: "{{active_queue|待处理队列}}"
              [TEXT: queue_summary_text]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{queue_summary|统一承接审批动作、队列切换与结果筛选}}"

      [CARD: queue_tabs_card]
        ATTR: Variant("fit365-panel")
        [CARD_CONTENT: queue_tabs_content]
          [STACK: queue_tabs_stack]
            ATTR: ClassName("space-y-4 px-6 py-5")
            [TABS: queue_tabs]
              ATTR: DefaultValue("pending")
              [TABS_LIST: queue_tab_list]
                [TABS_TRIGGER: trigger_pending]
                  ATTR: Value("pending")
                  CONTENT: "待处理"
                [TABS_TRIGGER: trigger_in_progress]
                  ATTR: Value("in_progress")
                  CONTENT: "处理中"
                [TABS_TRIGGER: trigger_completed]
                  ATTR: Value("completed")
                  CONTENT: "已完成"
                [TABS_TRIGGER: trigger_all]
                  ATTR: Value("all")
                  CONTENT: "全部"
              [TABS_CONTENT: content_pending]
                ATTR: Value("pending")
                [TEXT: pending_placeholder]
                  CONTENT: "待处理任务列表"
              [TABS_CONTENT: content_in_progress]
                ATTR: Value("in_progress")
                [TEXT: in_progress_placeholder]
                  CONTENT: "处理中任务列表"
              [TABS_CONTENT: content_completed]
                ATTR: Value("completed")
                [TEXT: completed_placeholder]
                  CONTENT: "已完成任务列表"
              [TABS_CONTENT: content_all]
                ATTR: Value("all")
                [TEXT: all_placeholder]
                  CONTENT: "全部任务列表"
            [SEPARATOR: queue_divider]
            [FLEX: filter_row]
              { Gap: 4, Align: "End", Wrap: true }
              [STACK: filter_fields]
                BIND: Filters("read")
              [BUTTON: filter_submit]
                ATTR: Variant("secondary"), Click("filter_submit")
                CONTENT: "查询"

  [SECTION: task_list_section]
    [SPLIT: main_split]
      ATTR: Ratio("2:3")
      [CARD: task_list_panel]
        ATTR: Variant("fit365-shell")
        [CARD_HEADER: task_list_header]
          [CARD_TITLE: task_list_title]
            CONTENT: "待办队列"
          [CARD_DESCRIPTION: task_list_desc]
            CONTENT: "{{task_list_desc|左侧集中展示待办项，便于快速审阅与切换}}"
        [CARD_CONTENT: task_list_content]
          [STACK: task_list]
            { Gap: 3 }
            [FOR: task in tasks]
              [CARD: task_card]
                ATTR: Variant("fit365-soft")
                [CARD_HEADER: task_card_header]
                  [FLEX: task_card_header_row]
                    { Justify: "Between", Align: "Center", Wrap: true, Gap: 2 }
                    [STACK: task_card_meta]
                      { Gap: 1 }
                      [CARD_TITLE: task_card_title]
                        CONTENT: "{{task.title|待办事项}}"
                      [CARD_DESCRIPTION: task_card_desc]
                        CONTENT: "{{task.subtitle|可在详情面板查看完整上下文}}"
                    [BADGE: task_card_status]
                      ATTR: Variant("secondary")
                      CONTENT: "{{task.status|待处理}}"
                [CARD_CONTENT: task_content]
                  [STACK: task_fields]
                    BIND: Fields("*")
                [CARD_FOOTER: task_card_footer]
                  [TEXT: task_card_footer_text]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{task.next_step|点击后在右侧查看详情与动作}}"
            [/FOR]
            [IF: tasks_empty]
              [EMPTY_STATE: no_tasks]
                ATTR: Description("当前没有待处理的任务")
            [/IF]
      [STACK: detail_panel]
        [CARD: task_detail_card]
          ATTR: ClassName("rounded-[24px] border-[var(--color-primary-light-1)] bg-[var(--color-bg-card)] shadow-[var(--shadow-medium)]")
          [CARD_HEADER: task_detail_header]
            [STACK: task_detail_header_stack]
              { Gap: 2 }
              [CARD_TITLE: task_detail_title]
                CONTENT: "{{selected_task.title|请选择任务}}"
              [CARD_DESCRIPTION: task_detail_desc]
                CONTENT: "{{selected_task.summary|右侧面板承接详情、说明与审批动作}}"
          [CARD_CONTENT: task_detail_content]
            [STACK: task_detail_info]
              { Gap: 3 }
              [BADGE: task_detail_status]
                ATTR: Variant("outline")
                CONTENT: "{{selected_task.status|等待选择}}"
              [TEXT: task_detail_fields]
                CONTENT: "任务详情区域"
          [CARD_FOOTER: task_detail_footer]
            [FLEX: detail_actions]
              BIND: Actions("*")
