[PAGE: department_list]
  ATTR: Title("部门管理列表")

  [SECTION: department_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: department_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|部门管理列表}}"
    [BUTTON: department_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: department_filter_card]
    [CARD_CONTENT: department_filter_content]
      [FLEX: department_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_status]
          ATTR: Name("status"), Label("状态")
        [BUTTON: department_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: department_table]
    [TABLE_HEADER: department_table_header]
      [TABLE_ROW: department_header_row]
        [TABLE_HEAD: th_department_name]
          CONTENT: "部门名称"
        [TABLE_HEAD: th_parent_department]
          CONTENT: "上级部门"
        [TABLE_HEAD: th_manager_name]
          CONTENT: "负责人"
        [TABLE_HEAD: th_employee_count]
          CONTENT: "人数"
        [TABLE_HEAD: th_status]
          CONTENT: "状态"
    [TABLE_BODY: department_table_body]
      [FOR: row in rows]
        [TABLE_ROW: department_row]
          [TABLE_CELL: td_department_name]
            CONTENT: "{{row.department_name|}}"
          [TABLE_CELL: td_parent_department]
            CONTENT: "{{row.parent_department|}}"
          [TABLE_CELL: td_manager_name]
            CONTENT: "{{row.manager_name|}}"
          [TABLE_CELL: td_employee_count]
            CONTENT: "{{row.employee_count|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: department_no_data]
      ATTR: Description("暂无部门数据")
  [/IF]
