[PAGE: scheduling_period_detail]
  META: Entity("SchedulingPeriod"), Domain("Scheduling")
  ATTR: Title("排班周期详情")

  [SECTION: breadcrumb_section]
    [BREADCRUMB: period_breadcrumb]
      [BREADCRUMB_LIST: bc_list]
        [BREADCRUMB_ITEM: bc_list_item]
          [BREADCRUMB_LINK: bc_link]
            ATTR: Patch("/scheduling/periods")
            CONTENT: "排班周期管理"
        [BREADCRUMB_SEPARATOR: bc_sep]
        [BREADCRUMB_ITEM: bc_current_item]
          [BREADCRUMB_PAGE: bc_current]
            CONTENT: "{{record.title|详情}}"

  [SECTION: detail_header]
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [FLEX: title_group]
        { Gap: 3, Align: "Center" }
        [TEXT: detail_title]
          ATTR: Variant("title")
          CONTENT: "{{record.title|}}"
        [BADGE: state_badge]
          BIND: Enum("state")
          CONTENT: "{{record.state|}}"
        [BADGE: mode_badge]
          ATTR: Variant("secondary")
          BIND: Enum("generation_mode")
          CONTENT: "{{record.generation_mode|}}"
      [FLEX: actions_group]
        { Gap: 2 }
        [BUTTON: edit_btn]
          ATTR: Variant("secondary"), Click("toggle_edit")
          CONTENT: "编辑"
        [BUTTON: generate_btn]
          ATTR: Variant("primary"), Click("action_start_generating")
          CONTENT: "开始自动排班"
        [BUTTON: publish_btn]
          ATTR: Variant("primary"), Click("action_publish")
          CONTENT: "发布"

  [SECTION: info_section]
    [GRID: info_cards]
      { Columns: 4, Gap: 3 }
      [CARD: dept_card]
        [CARD_CONTENT: dept_content]
          [STACK: dept_stat]
            { Gap: 0 }
            [TEXT: dept_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "科室"
            [TEXT: dept_value]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "{{record.department.name|}}"
      [CARD: date_card]
        [CARD_CONTENT: date_content]
          [STACK: date_stat]
            { Gap: 0 }
            [TEXT: date_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "日期范围"
            [TEXT: date_value]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "{{record.start_date|}} ~ {{record.end_date|}}"
      [CARD: version_card]
        [CARD_CONTENT: version_content]
          [STACK: version_stat]
            { Gap: 0 }
            [TEXT: version_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "当前版本"
            [TEXT: version_value]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "v{{record.current_version.version_no|}}"
      [CARD: run_card]
        [CARD_CONTENT: run_content]
          [STACK: run_stat]
            { Gap: 0 }
            [TEXT: run_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "最近求解"
            [BADGE: run_status_badge]
              BIND: Enum("status", entity: "SolverRun")
              CONTENT: "{{record.last_solver_run.status|}}"

  [SECTION: nav_section]
    [GRID: nav_grid]
      { Columns: 3, Gap: 3 }
      [CARD: req_nav_card]
        [CARD_HEADER: req_nav_header]
          [CARD_TITLE: req_nav_title]
            CONTENT: "需求矩阵"
        [CARD_CONTENT: req_nav_content]
          [TEXT: req_nav_desc]
            ATTR: Variant("muted")
            CONTENT: "编辑日期×班次的人员需求"
          [BUTTON: req_nav_btn]
            ATTR: Variant("outline"), Click("navigate_requirements")
            CONTENT: "进入需求矩阵"
      [CARD: constraint_nav_card]
        [CARD_HEADER: constraint_nav_header]
          [CARD_TITLE: constraint_nav_title]
            CONTENT: "约束配置"
        [CARD_CONTENT: constraint_nav_content]
          [TEXT: constraint_nav_desc]
            ATTR: Variant("muted")
            CONTENT: "管理排班规则和权重"
          [BUTTON: constraint_nav_btn]
            ATTR: Variant("outline"), Click("navigate_constraints")
            CONTENT: "进入约束配置"
      [CARD: calendar_nav_card]
        [CARD_HEADER: calendar_nav_header]
          [CARD_TITLE: calendar_nav_title]
            CONTENT: "日历调班"
        [CARD_CONTENT: calendar_nav_content]
          [TEXT: calendar_nav_desc]
            ATTR: Variant("muted")
            CONTENT: "查看和调整排班结果"
          [BUTTON: calendar_nav_btn]
            ATTR: Variant("outline"), Click("navigate_calendar")
            CONTENT: "进入日历调班"

  [SECTION: versions_section]
    [CARD: versions_card]
      [CARD_HEADER: versions_header]
        [CARD_TITLE: versions_title]
          CONTENT: "版本历史"
      [CARD_CONTENT: versions_content]
        [TABLE: versions_table]
          [TABLE_HEADER: ver_header]
            [TABLE_ROW: ver_header_row]
              [TABLE_HEAD: th_ver_no]
                CONTENT: "版本号"
              [TABLE_HEAD: th_ver_status]
                CONTENT: "状态"
              [TABLE_HEAD: th_ver_origin]
                CONTENT: "来源"
              [TABLE_HEAD: th_ver_summary]
                CONTENT: "说明"
              [TABLE_HEAD: th_ver_created]
                CONTENT: "创建时间"
          [TABLE_BODY: ver_body]
            [FOR: ver in record.schedule_versions]
              [TABLE_ROW: ver_row]
                [TABLE_CELL: td_ver_no]
                  CONTENT: "v{{ver.version_no|}}"
                [TABLE_CELL: td_ver_status]
                  [BADGE: ver_status_badge]
                    BIND: Enum("status", entity: "ScheduleVersion")
                    CONTENT: "{{ver.status|}}"
                [TABLE_CELL: td_ver_origin]
                  [BADGE: ver_origin_badge]
                    ATTR: Variant("secondary")
                    BIND: Enum("origin_type")
                    CONTENT: "{{ver.origin_type|}}"
                [TABLE_CELL: td_ver_summary]
                  CONTENT: "{{ver.change_summary|}}"
                [TABLE_CELL: td_ver_created]
                  CONTENT: "{{ver.inserted_at|}}"
            [/FOR]

  [SECTION: runs_section]
    [CARD: runs_card]
      [CARD_HEADER: runs_header]
        [CARD_TITLE: runs_title]
          CONTENT: "求解记录"
      [CARD_CONTENT: runs_content]
        [TABLE: runs_table]
          [TABLE_HEADER: run_header]
            [TABLE_ROW: run_header_row]
              [TABLE_HEAD: th_run_engine]
                CONTENT: "算法"
              [TABLE_HEAD: th_run_status]
                CONTENT: "状态"
              [TABLE_HEAD: th_run_score]
                CONTENT: "评分"
              [TABLE_HEAD: th_run_violations]
                CONTENT: "违反数"
              [TABLE_HEAD: th_run_time]
                CONTENT: "执行时间"
          [TABLE_BODY: run_body]
            [FOR: run in record.solver_runs]
              [TABLE_ROW: run_row]
                [TABLE_CELL: td_run_engine]
                  CONTENT: "{{run.engine_type|}}"
                [TABLE_CELL: td_run_status]
                  [BADGE: run_status]
                    BIND: Enum("status", entity: "SolverRun")
                    CONTENT: "{{run.status|}}"
                [TABLE_CELL: td_run_score]
                  CONTENT: "{{run.score|}}"
                [TABLE_CELL: td_run_violations]
                  CONTENT: "{{run.hard_violation_count|}}"
                [TABLE_CELL: td_run_time]
                  CONTENT: "{{run.started_at|}} ~ {{run.completed_at|}}"
            [/FOR]
