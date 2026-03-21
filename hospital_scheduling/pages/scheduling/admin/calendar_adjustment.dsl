EXTENDS: base_calendar_schedule
META: Entity("ShiftAssignment"), Domain("Scheduling")

[PAGE: calendar_adjustment]
  ATTR: Title("日历调班")

  OVERRIDE: section("date_nav_section")
    [FLEX: date_navigator]
      { Justify: "Between", Align: "Center" }
      [FLEX: nav_left]
        { Gap: 2, Align: "Center" }
        [BUTTON: prev_week_btn]
          ATTR: Variant("outline"), Size("sm"), Click("navigate_prev_week")
          CONTENT: "上一周"
        [TEXT: current_week]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "{{current_week_label|}}"
        [BUTTON: next_week_btn]
          ATTR: Variant("outline"), Size("sm"), Click("navigate_next_week")
          CONTENT: "下一周"
      [FLEX: nav_right]
        { Gap: 2 }
        [BADGE: period_badge]
          CONTENT: "{{period.title|}}"
        [BUTTON: back_btn]
          ATTR: Variant("secondary"), Click("navigate_back")
          CONTENT: "返回周期详情"

  OVERRIDE: section("resource_section")
    [FLEX: resource_filter]
      { Gap: 4, Align: "Center", Wrap: true }
      [SELECT: filter_role]
        ATTR: Name("role_code"), Label("岗位筛选")
      [SELECT: filter_shift_type]
        ATTR: Name("shift_type_id"), Label("班次类型")
      [BUTTON: filter_submit]
        ATTR: Variant("secondary"), Click("filter_submit")
        CONTENT: "筛选"

  OVERRIDE: section("matrix_section")
    [CARD: calendar_card]
      [CARD_CONTENT: calendar_content]
        [TABLE: calendar_table]
          [TABLE_HEADER: cal_header]
            [TABLE_ROW: cal_header_row]
              [TABLE_HEAD: th_employee]
                CONTENT: "员工"
              [TABLE_HEAD: th_days]
                CONTENT: "日期列（由当前周日期动态生成）"
          [TABLE_BODY: cal_body]
            [FOR: emp in employees]
              [TABLE_ROW: emp_row]
                [TABLE_CELL: td_emp_name]
                  [STACK: emp_info]
                    { Gap: 0 }
                    [TEXT: emp_name]
                      ATTR: Weight("bold")
                      CONTENT: "{{emp.name|}}"
                    [TEXT: emp_role]
                      ATTR: Variant("caption"), Color("muted")
                      CONTENT: "{{emp.role_code|}}"
                [TABLE_CELL: td_assignments]
                  [FOR: day in emp.daily_assignments]
                    [BADGE: shift_badge]
                      CONTENT: "{{day.shift_type.name|}}"
                  [/FOR]
            [/FOR]

  OVERRIDE: section("summary_section")
    [GRID: summary_grid]
      { Columns: 2, Gap: 3 }
      [CARD: stats_card]
        [CARD_HEADER: stats_header]
          [CARD_TITLE: stats_title]
            CONTENT: "调班统计"
        [CARD_CONTENT: stats_content]
          [STACK: stats_list]
            { Gap: 2 }
            [FLEX: stat_manual_changes]
              { Justify: "Between" }
              [TEXT: manual_label]
                CONTENT: "手动调整次数"
              [TEXT: manual_value]
                ATTR: Weight("bold")
                CONTENT: "{{manual_change_count|}}"
            [FLEX: stat_coverage]
              { Justify: "Between" }
              [TEXT: coverage_label]
                CONTENT: "需求覆盖率"
              [TEXT: coverage_value]
                ATTR: Weight("bold")
                CONTENT: "{{coverage_rate|}}%"
      [CARD: violations_card]
        [CARD_HEADER: violations_header]
          [CARD_TITLE: violations_title]
            CONTENT: "实时约束检查"
        [CARD_CONTENT: violations_content]
          [FOR: vio in live_violations]
            [FLEX: vio_item]
              { Gap: 2, Align: "Center" }
              [BADGE: vio_severity]
                BIND: Enum("ConstraintViolation", "severity")
                CONTENT: "{{vio.severity|}}"
              [TEXT: vio_message]
                ATTR: Variant("caption")
                CONTENT: "{{vio.message|}}"
          [/FOR]
          [IF: no_violations]
            [EMPTY_STATE: no_vio_state]
              ATTR: Description("无约束违反")
          [/IF]

  [SECTION: bottom_actions]
    [FLEX: action_bar]
      { Justify: "End", Gap: 2 }
      [BUTTON: save_draft_btn]
        ATTR: Variant("secondary"), Click("save_draft")
        CONTENT: "保存草稿"
      [BUTTON: publish_preview_btn]
        ATTR: Variant("primary"), Click("navigate_publish_preview")
        CONTENT: "发布预览"
