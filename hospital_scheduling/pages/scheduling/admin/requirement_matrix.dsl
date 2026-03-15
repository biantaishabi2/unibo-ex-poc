[PAGE: requirement_matrix]
  META: Entity("CoverageRequirement"), Domain("Scheduling")
  ATTR: Title("需求矩阵")

  [SECTION: header]
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [STACK: title_group]
        { Gap: 1 }
        [TEXT: page_title]
          ATTR: Variant("title")
          CONTENT: "{{period.title|需求矩阵}}"
        [FLEX: subtitle_row]
          { Gap: 2 }
          [BADGE: state_badge]
            CONTENT: "{{period.state|}}"
          [TEXT: date_range]
            ATTR: Variant("muted")
            CONTENT: "{{period.start_date|}} ~ {{period.end_date|}}"
      [BUTTON: back_btn]
        ATTR: Variant("secondary"), Click("navigate_back")
        CONTENT: "返回周期详情"

  [SECTION: matrix_section]
    [CARD: matrix_card]
      [CARD_HEADER: matrix_header]
        [FLEX: matrix_toolbar]
          { Justify: "Between", Align: "Center" }
          [TEXT: matrix_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "覆盖需求矩阵"
          [FLEX: matrix_actions]
            { Gap: 2 }
            [SELECT: filter_role]
              ATTR: Name("role_code"), Label("岗位筛选")
            [BUTTON: batch_fill_btn]
              ATTR: Variant("secondary"), Click("batch_fill_requirements")
              CONTENT: "批量填充"
      [CARD_CONTENT: matrix_content]
        # 日期×班次矩阵网格
        [TABLE: req_matrix_table]
          [TABLE_HEADER: req_matrix_header]
            [TABLE_ROW: matrix_header_row]
              [TABLE_HEAD: th_shift]
                CONTENT: "班次 / 日期"
              [TABLE_HEAD: th_dates]
                CONTENT: "日期列（由周期日期范围动态生成）"
          [TABLE_BODY: req_matrix_body]
            [FOR: shift in shift_types]
              [TABLE_ROW: shift_row]
                [TABLE_CELL: td_shift_name]
                  [BADGE: shift_name_badge]
                    CONTENT: "{{shift.name|}}"
                [TABLE_CELL: td_requirements]
                  [FOR: req in shift.requirements]
                    [STACK: req_cell]
                      { Gap: 0 }
                      [TEXT: min_count]
                        ATTR: Variant("caption")
                        CONTENT: "最低 {{req.min_headcount|}}"
                      [TEXT: target_count]
                        ATTR: Variant("caption"), Color("muted")
                        CONTENT: "目标 {{req.target_headcount|}}"
                  [/FOR]
            [/FOR]

  [SECTION: actions_section]
    [FLEX: bottom_actions]
      { Justify: "End", Gap: 2 }
      [BUTTON: save_btn]
        ATTR: Variant("primary"), Click("save_requirements")
        CONTENT: "保存修改"
      [BUTTON: start_btn]
        ATTR: Variant("primary"), Click("action_start_generating")
        CONTENT: "开始自动排班"
