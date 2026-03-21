[PAGE: employee_list]
  META: Entity("TravelOrder"), Domain("Travel")
  ATTR: Title("员工管理列表")

  [SECTION: employee_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: employee_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|员工管理列表}}"
    [BUTTON: employee_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: employee_filter_card]
    [CARD_CONTENT: employee_filter_content]
      [FLEX: employee_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_status]
          ATTR: Name("status"), Label("状态")
          BIND: Enum("TravelOrder", "status")
        [SELECT: filter_department]
          ATTR: Name("department"), Label("部门")
        [BUTTON: employee_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: employee_table]
    [TABLE_HEADER: employee_table_header]
      [TABLE_ROW: employee_header_row]
        [TABLE_HEAD: th_employee_name]
          CONTENT: "姓名"
        [TABLE_HEAD: th_department]
          CONTENT: "部门"
        [TABLE_HEAD: th_job_position]
          CONTENT: "职级"
        [TABLE_HEAD: th_phone]
          CONTENT: "手机号"
        [TABLE_HEAD: th_status]
          CONTENT: "状态"
    [TABLE_BODY: employee_table_body]
      [FOR: row in rows]
        [TABLE_ROW: employee_row]
          [TABLE_CELL: td_employee_name]
            CONTENT: "{{row.employee_name|}}"
          [TABLE_CELL: td_department]
            CONTENT: "{{row.department|}}"
          [TABLE_CELL: td_job_position]
            CONTENT: "{{row.job_position|}}"
          [TABLE_CELL: td_phone]
            CONTENT: "{{row.phone|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: employee_no_data]
      ATTR: Description("暂无员工数据")
  [/IF]
