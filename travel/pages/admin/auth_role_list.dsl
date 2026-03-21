[PAGE: auth_role_list]
  META: Entity("TravelPolicy"), Domain("Travel")
  ATTR: Title("角色权限列表")

  [SECTION: auth_role_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: auth_role_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|角色权限列表}}"
    [BUTTON: auth_role_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: auth_role_filter_card]
    [CARD_CONTENT: auth_role_filter_content]
      [FLEX: auth_role_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_status]
          ATTR: Name("status"), Label("状态")
        [BUTTON: auth_role_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: auth_role_table]
    BIND: Fields("*")
    [TABLE_HEADER: auth_role_table_header]
      [TABLE_ROW: auth_role_header_row]
        [TABLE_HEAD: th_role_name]
          CONTENT: "角色名称"
        [TABLE_HEAD: th_role_code]
          CONTENT: "角色编码"
        [TABLE_HEAD: th_description]
          CONTENT: "描述"
        [TABLE_HEAD: th_member_count]
          CONTENT: "成员数"
        [TABLE_HEAD: th_status]
          CONTENT: "状态"
    [TABLE_BODY: auth_role_table_body]
      [FOR: row in rows]
        [TABLE_ROW: auth_role_row]
          [TABLE_CELL: td_role_name]
            CONTENT: "{{row.role_name|}}"
          [TABLE_CELL: td_role_code]
            CONTENT: "{{row.role_code|}}"
          [TABLE_CELL: td_description]
            CONTENT: "{{row.description|}}"
          [TABLE_CELL: td_member_count]
            CONTENT: "{{row.member_count|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: auth_role_no_data]
      ATTR: Description("暂无角色权限数据")
  [/IF]
