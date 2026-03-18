[PAGE: publish_preview]
  META: Entity("ScheduleVersion"), Domain("Scheduling")
  ATTR: Title("发布预览")

  [SECTION: header]
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [STACK: title_group]
        { Gap: 1 }
        [TEXT: page_title]
          ATTR: Variant("title")
          CONTENT: "发布预览 — {{period.title|}}"
        [FLEX: subtitle_row]
          { Gap: 2 }
          [BADGE: version_badge]
            CONTENT: "v{{version.version_no|}}"
          [BADGE: origin_badge]
            ATTR: Variant("secondary")
            CONTENT: "{{version.origin_type|}}"
      [BUTTON: back_btn]
        ATTR: Variant("secondary"), Click("navigate_back")
        CONTENT: "返回日历调班"

  [SECTION: error_guard_section]
    [IF: has_hard_violations]
      [ALERT: block_alert]
        ATTR: Variant("destructive"), Title("无法发布"), Description("当前版本存在 {{hard_violation_count|}} 个硬约束违反，必须全部解决后才能发布。请返回日历调班页手动调整。")
    [/IF]
    [IF: has_warnings]
      [ALERT: warn_alert]
        ATTR: Variant("warning"), Title("存在警告"), Description("有 {{warning_count|}} 个软约束警告，可选择忽略并继续发布。")
    [/IF]

  [SECTION: diff_section]
    [CARD: diff_card]
      [CARD_HEADER: diff_header]
        [FLEX: diff_toolbar]
          { Justify: "Between", Align: "Center" }
          [CARD_TITLE: diff_title]
            CONTENT: "变更对比"
          [FLEX: diff_controls]
            { Gap: 2 }
            [SELECT: diff_base]
              ATTR: Name("base_version"), Label("对比基准")
            [BUTTON: toggle_diff_btn]
              ATTR: Variant("outline"), Size("sm"), Click("toggle_diff_mode")
              CONTENT: "切换视图"
      [CARD_CONTENT: diff_content]
        [TABLE: diff_table]
          [TABLE_HEADER: diff_table_header]
            [TABLE_ROW: diff_header_row]
              [TABLE_HEAD: th_employee]
                CONTENT: "员工"
              [TABLE_HEAD: th_date]
                CONTENT: "日期"
              [TABLE_HEAD: th_old_shift]
                CONTENT: "原班次"
              [TABLE_HEAD: th_new_shift]
                CONTENT: "新班次"
              [TABLE_HEAD: th_reason]
                CONTENT: "变更原因"
          [TABLE_BODY: diff_table_body]
            [FOR: change in changes]
              [TABLE_ROW: change_row]
                [TABLE_CELL: td_change_emp]
                  CONTENT: "{{change.employee.name|}}"
                [TABLE_CELL: td_change_date]
                  CONTENT: "{{change.date|}}"
                [TABLE_CELL: td_old]
                  [BADGE: old_shift_badge]
                    ATTR: Variant("secondary")
                    CONTENT: "{{change.old_shift_type|}}"
                [TABLE_CELL: td_new]
                  [BADGE: new_shift_badge]
                    CONTENT: "{{change.new_shift_type|}}"
                [TABLE_CELL: td_reason]
                  CONTENT: "{{change.reason|}}"
            [/FOR]
        [IF: no_changes]
          [EMPTY_STATE: no_changes_state]
            ATTR: Description("与基准版本无差异")
        [/IF]

  [SECTION: summary_section]
    [GRID: summary_grid]
      { Columns: 3, Gap: 3 }
      [CARD: change_count_card]
        [CARD_CONTENT: change_count_content]
          [STACK: change_stat]
            { Gap: 0 }
            [TEXT: change_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "变更数量"
            [TEXT: change_value]
              ATTR: Variant("h3"), Weight("bold")
              CONTENT: "{{change_count|}}"
      [CARD: affected_emp_card]
        [CARD_CONTENT: affected_emp_content]
          [STACK: affected_stat]
            { Gap: 0 }
            [TEXT: affected_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "涉及员工"
            [TEXT: affected_value]
              ATTR: Variant("h3"), Weight("bold")
              CONTENT: "{{affected_employee_count|}}"
      [CARD: coverage_card]
        [CARD_CONTENT: coverage_content]
          [STACK: coverage_stat]
            { Gap: 0 }
            [TEXT: coverage_label]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "需求覆盖率"
            [TEXT: coverage_value]
              ATTR: Variant("h3"), Weight("bold")
              CONTENT: "{{coverage_rate|}}%"

  [SECTION: publish_actions]
    [FLEX: action_bar]
      { Justify: "End", Gap: 2 }
      [BUTTON: cancel_btn]
        ATTR: Variant("secondary"), Click("navigate_back")
        CONTENT: "返回修改"
      [BUTTON: publish_btn]
        ATTR: Variant("primary"), Click("action_publish"), Disabled("{{has_hard_violations|}}")
        CONTENT: "确认发布"
