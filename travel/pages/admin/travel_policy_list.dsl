[PAGE: travel_policy_list]
  META: Entity("TravelPolicy"), Domain("Travel")
  ATTR: Title("TravelPolicy 列表")

  [SECTION: travel_policy_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: travel_policy_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TravelPolicy 列表}}"
    [BUTTON: travel_policy_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: travel_policy_filter_card]
    [CARD_CONTENT: travel_policy_filter_content]
      [FLEX: travel_policy_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_product_type]
          ATTR: Name("product_type"), Label("适用商品类型")
          BIND: Enum("TravelPolicy", "product_type")
        [BUTTON: travel_policy_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: travel_policy_table]
    [TABLE_HEADER: travel_policy_table_header]
      [TABLE_ROW: travel_policy_header_row]
        [TABLE_HEAD: th_policy_name]
          CONTENT: "政策名称"
        [TABLE_HEAD: th_product_type]
          CONTENT: "适用商品类型"
        [TABLE_HEAD: th_employee_level]
          CONTENT: "职级标识"
        [TABLE_HEAD: th_exceed_strategy]
          CONTENT: "超标处理策略"
        [TABLE_HEAD: th_max_amount]
          CONTENT: "金额上限"
        [TABLE_HEAD: th_is_active]
          CONTENT: "是否启用"
    [TABLE_BODY: travel_policy_table_body]
      [FOR: row in rows]
        [TABLE_ROW: travel_policy_row]
          [TABLE_CELL: td_policy_name]
            CONTENT: "{{row.policy_name|}}"
          [TABLE_CELL: td_product_type]
            [BADGE: badge_product_type]
              CONTENT: "{{row.product_type|}}"
          [TABLE_CELL: td_employee_level]
            CONTENT: "{{row.employee_level|}}"
          [TABLE_CELL: td_exceed_strategy]
            [BADGE: badge_exceed_strategy]
              CONTENT: "{{row.exceed_strategy|}}"
          [TABLE_CELL: td_max_amount]
            CONTENT: "{{row.max_amount|}}"
          [TABLE_CELL: td_is_active]
            CONTENT: "{{row.is_active|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: travel_policy_no_data]
      ATTR: Description("暂无差旅政策数据")
  [/IF]
