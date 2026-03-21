EXTENDS: base_overview
META: Entity("SolverRun"), Domain("Scheduling")

[PAGE: solver_result]
  ATTR: Title("排班结果")

  OVERRIDE: section("kpi_cards")
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [STACK: title_group]
        { Gap: 1 }
        [TEXT: page_title]
          ATTR: Variant("title")
          CONTENT: "排班结果 — {{period.title|}}"
        [FLEX: subtitle_row]
          { Gap: 2 }
          [BADGE: run_status_badge]
            CONTENT: "{{run.status|}}"
          [TEXT: engine_info]
            ATTR: Variant("muted")
            CONTENT: "算法: {{run.engine_type|}}"
      [BUTTON: back_btn]
        ATTR: Variant("secondary"), Click("navigate_back")
        CONTENT: "返回周期详情"

    [GRID: kpi_grid]
      { Columns: 4, Gap: 3 }
      [CARD: kpi_assignments]
        [CARD_CONTENT: kpi_assignments_content]
          [STACK: kpi_assignments_stat]
            { Gap: 0 }
            [TEXT: kpi_assignments_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "总分配数"
            [TEXT: kpi_assignments_value]
              ATTR: Variant("h3"), Weight("bold")
              CONTENT: "{{run.output_snapshot.summary.assignment_count|}}"
      [CARD: kpi_covered]
        [CARD_CONTENT: kpi_covered_content]
          [STACK: kpi_covered_stat]
            { Gap: 0 }
            [TEXT: kpi_covered_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "覆盖需求数"
            [TEXT: kpi_covered_value]
              ATTR: Variant("h3"), Weight("bold")
              CONTENT: "{{run.output_snapshot.summary.covered_requirement_count|}}"
      [CARD: kpi_errors]
        [CARD_CONTENT: kpi_errors_content]
          [STACK: kpi_errors_stat]
            { Gap: 0 }
            [TEXT: kpi_errors_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "硬约束违反"
            [TEXT: kpi_errors_value]
              ATTR: Variant("h3"), Weight("bold"), Color("destructive")
              CONTENT: "{{run.hard_violation_count|}}"
      [CARD: kpi_warnings]
        [CARD_CONTENT: kpi_warnings_content]
          [STACK: kpi_warnings_stat]
            { Gap: 0 }
            [TEXT: kpi_warnings_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "警告数"
            [TEXT: kpi_warnings_value]
              ATTR: Variant("h3"), Weight("bold")
              CONTENT: "{{run.warning_count|}}"

  OVERRIDE: section("charts")
    [IF: has_hard_violations]
      [ALERT: error_alert]
        ATTR: Variant("destructive"), Title("存在硬约束违反"), Description("有 {{run.hard_violation_count|}} 个硬约束违反需要处理，建议进入日历调班页手动调整。")
    [/IF]

    [CARD: violations_card]
      [CARD_HEADER: violations_header]
        [CARD_TITLE: violations_title]
          CONTENT: "约束违反明细"
      [CARD_CONTENT: violations_content]
        [TABLE: violations_table]
          [TABLE_HEADER: vio_header]
            [TABLE_ROW: vio_header_row]
              [TABLE_HEAD: th_severity]
                CONTENT: "级别"
              [TABLE_HEAD: th_rule]
                CONTENT: "规则编码"
              [TABLE_HEAD: th_message]
                CONTENT: "说明"
          [TABLE_BODY: vio_body]
            [FOR: vio in violations]
              [TABLE_ROW: vio_row]
                [TABLE_CELL: td_severity]
                  [BADGE: severity_badge]
                    CONTENT: "{{vio.severity|}}"
                [TABLE_CELL: td_rule]
                  CONTENT: "{{vio.rule_code|}}"
                [TABLE_CELL: td_message]
                  CONTENT: "{{vio.message|}}"
            [/FOR]
        [IF: violations_empty]
          [EMPTY_STATE: no_violations]
            ATTR: Description("无约束违反，排班结果良好")
        [/IF]

  OVERRIDE: section("activity_feed")
    [FLEX: action_bar]
      { Justify: "End", Gap: 2 }
      [BUTTON: calendar_btn]
        ATTR: Variant("primary"), Click("navigate_calendar")
        CONTENT: "进入日历调班"
      [BUTTON: publish_btn]
        ATTR: Variant("secondary"), Click("navigate_publish_preview")
        CONTENT: "直接发布预览"
