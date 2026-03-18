[PAGE: scheduling_period_list]
  EXTENDS: base_list_report
  META: Entity("SchedulingPeriod"), Domain("Scheduling")

  OVERRIDE: section("header")
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [TEXT: page_title]
        ATTR: Variant("title")
        CONTENT: "{{page_title|排班周期管理}}"
      [BUTTON: create_btn]
        ATTR: Variant("primary"), Click("navigate_create")
        CONTENT: "新建排班周期"

  OVERRIDE: section("filter_section")
    [CARD: filter_card]
      [CARD_CONTENT: filter_content]
        [FLEX: filter_row]
          { Gap: 4, Align: "Center" }
          [SELECT: filter_state]
            BIND: Enum("state")
            ATTR: Name("state"), Label("状态")
          [SELECT: filter_department]
            ATTR: Name("department_id"), Label("科室")
          [INPUT: filter_start_date]
            ATTR: Name("start_date_from"), Label("起始日期"), Type("date")
          [BUTTON: filter_submit]
            ATTR: Variant("secondary"), Click("filter_submit")
            CONTENT: "查询"

  OVERRIDE: section("table_section")
    [TABLE: period_table]
      [TABLE_HEADER: period_header]
        [TABLE_ROW: header_row]
          [TABLE_HEAD: th_title]
            CONTENT: "周期名称"
          [TABLE_HEAD: th_department]
            CONTENT: "科室"
          [TABLE_HEAD: th_start_date]
            CONTENT: "开始日期"
          [TABLE_HEAD: th_end_date]
            CONTENT: "结束日期"
          [TABLE_HEAD: th_state]
            CONTENT: "状态"
          [TABLE_HEAD: th_generation_mode]
            CONTENT: "生成方式"
          [TABLE_HEAD: th_actions]
            CONTENT: "操作"
      [TABLE_BODY: period_body]
        [FOR: row in rows]
          [TABLE_ROW: period_row]
            [TABLE_CELL: td_title]
              CONTENT: "{{row.title|}}"
            [TABLE_CELL: td_department]
              CONTENT: "{{row.department.name|}}"
            [TABLE_CELL: td_start_date]
              CONTENT: "{{row.start_date|}}"
            [TABLE_CELL: td_end_date]
              CONTENT: "{{row.end_date|}}"
            [TABLE_CELL: td_state]
              [BADGE: state_badge]
                BIND: Enum("state")
                CONTENT: "{{row.state|}}"
            [TABLE_CELL: td_generation_mode]
              [BADGE: mode_badge]
                BIND: Enum("generation_mode")
                CONTENT: "{{row.generation_mode|}}"
            [TABLE_CELL: td_actions]
              [FLEX: row_actions]
                { Gap: 1 }
                [BUTTON: detail_btn]
                  ATTR: Variant("outline"), Size("sm"), Click("navigate_detail")
                  CONTENT: "详情"
                [BUTTON: delete_btn]
                  ATTR: Variant("destructive"), Size("sm"), Click("action_destroy")
                  CONTENT: "删除"
        [/FOR]
