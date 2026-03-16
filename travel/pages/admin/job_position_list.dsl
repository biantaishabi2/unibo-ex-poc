[PAGE: job_position_list]
  ATTR: Title("职级管理列表")

  [SECTION: job_position_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: job_position_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|职级管理列表}}"
    [BUTTON: job_position_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: job_position_filter_card]
    [CARD_CONTENT: job_position_filter_content]
      [FLEX: job_position_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_status]
          ATTR: Name("status"), Label("状态")
        [BUTTON: job_position_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: job_position_table]
    [TABLE_HEADER: job_position_table_header]
      [TABLE_ROW: job_position_header_row]
        [TABLE_HEAD: th_position_name]
          CONTENT: "职级名称"
        [TABLE_HEAD: th_position_level]
          CONTENT: "级别"
        [TABLE_HEAD: th_travel_level]
          CONTENT: "差旅等级"
        [TABLE_HEAD: th_employee_count]
          CONTENT: "人数"
        [TABLE_HEAD: th_status]
          CONTENT: "状态"
    [TABLE_BODY: job_position_table_body]
      [FOR: row in rows]
        [TABLE_ROW: job_position_row]
          [TABLE_CELL: td_position_name]
            CONTENT: "{{row.position_name|}}"
          [TABLE_CELL: td_position_level]
            CONTENT: "{{row.position_level|}}"
          [TABLE_CELL: td_travel_level]
            CONTENT: "{{row.travel_level|}}"
          [TABLE_CELL: td_employee_count]
            CONTENT: "{{row.employee_count|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: job_position_no_data]
      ATTR: Description("暂无职级数据")
  [/IF]
