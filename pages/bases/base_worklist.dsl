[PAGE: base_worklist]
  ATTR: Title("工作列表")
  [SECTION: queue_filters]
    [FLEX: queue_header]
      { Justify: "Between", Align: "Center" }
      [TEXT: page_title]
        ATTR: Variant("title")
        CONTENT: "{{page_title|工作列表}}"
      [FLEX: bulk_actions]
        { Gap: 2 }
        [BUTTON: bulk_approve]
          ATTR: Variant("primary"), Click("bulk_approve")
          CONTENT: "批量通过"
        [BUTTON: bulk_reject]
          ATTR: Variant("secondary"), Click("bulk_reject")
          CONTENT: "批量驳回"
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
    [FLEX: filter_row]
      { Gap: 4, Align: "Center" }
      [STACK: filter_fields]
        BIND: Filters("read")
      [BUTTON: filter_submit]
        ATTR: Variant("secondary"), Click("filter_submit")
        CONTENT: "查询"
  [SECTION: task_list_section]
    [SPLIT: main_split]
      ATTR: Ratio("2:3")
      [STACK: task_list]
        [FOR: task in tasks]
          [CARD: task_card]
            [CARD_CONTENT: task_content]
              [STACK: task_fields]
                BIND: Fields("*")
        [/FOR]
        [IF: tasks_empty]
          [EMPTY_STATE: no_tasks]
            ATTR: Description("当前没有待处理的任务")
        [/IF]
      [STACK: detail_panel]
        [CARD: task_detail_card]
          [CARD_HEADER: task_detail_header]
            [CARD_TITLE: task_detail_title]
              CONTENT: "{{selected_task.title|请选择任务}}"
          [CARD_CONTENT: task_detail_content]
            [STACK: task_detail_info]
              { Gap: 3 }
              [TEXT: task_detail_fields]
                CONTENT: "任务详情区域"
          [CARD_FOOTER: task_detail_footer]
            [FLEX: detail_actions]
              BIND: Actions("*")
