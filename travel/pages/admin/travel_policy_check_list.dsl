[PAGE: travel_policy_check_list]
  META: Entity("TravelPolicyCheck"), Domain("Travel")
  ATTR: Title("TravelPolicyCheck 列表")

  [SECTION: travel_policy_check_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: travel_policy_check_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TravelPolicyCheck 列表}}"

  [CARD: travel_policy_check_filter_card]
    [CARD_CONTENT: travel_policy_check_filter_content]
      [FLEX: travel_policy_check_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_check_result]
          ATTR: Name("check_result"), Label("校验结果")
          BIND: Enum("TravelPolicyCheck", "check_result")
        [BUTTON: travel_policy_check_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: travel_policy_check_table]
    [TABLE_HEADER: travel_policy_check_table_header]
      [TABLE_ROW: travel_policy_check_header_row]
        [TABLE_HEAD: th_order_id]
          CONTENT: "关联订单"
        [TABLE_HEAD: th_policy_id]
          CONTENT: "关联政策"
        [TABLE_HEAD: th_check_result]
          CONTENT: "校验结果"
        [TABLE_HEAD: th_actual_amount]
          CONTENT: "实际金额"
        [TABLE_HEAD: th_exceed_amount]
          CONTENT: "超标金额"
        [TABLE_HEAD: th_exceed_strategy]
          CONTENT: "命中的超标策略"
    [TABLE_BODY: travel_policy_check_table_body]
      [FOR: row in rows]
        [TABLE_ROW: travel_policy_check_row]
          [TABLE_CELL: td_order_id]
            CONTENT: "{{row.order_id|}}"
          [TABLE_CELL: td_policy_id]
            CONTENT: "{{row.policy_id|}}"
          [TABLE_CELL: td_check_result]
            [BADGE: badge_check_result]
              CONTENT: "{{row.check_result|}}"
          [TABLE_CELL: td_actual_amount]
            CONTENT: "{{row.actual_amount|}}"
          [TABLE_CELL: td_exceed_amount]
            CONTENT: "{{row.exceed_amount|}}"
          [TABLE_CELL: td_exceed_strategy]
            CONTENT: "{{row.exceed_strategy|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: travel_policy_check_no_data]
      ATTR: Description("暂无差旅政策校验记录数据")
  [/IF]
