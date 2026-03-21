[PAGE: travel_cabin_class_list]
  META: Entity("TravelCabinClass"), Domain("Travel")
  ATTR: Title("TravelCabinClass 列表")

  [SECTION: travel_cabin_class_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: travel_cabin_class_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TravelCabinClass 列表}}"
    [BUTTON: travel_cabin_class_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: travel_cabin_class_filter_card]
    [CARD_CONTENT: travel_cabin_class_filter_content]
      [FLEX: travel_cabin_class_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_status]
          ATTR: Name("status"), Label("status")
        [BUTTON: travel_cabin_class_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: travel_cabin_class_table]
    BIND: Fields("*")
    [TABLE_HEADER: travel_cabin_class_table_header]
      [TABLE_ROW: travel_cabin_class_header_row]
        [TABLE_HEAD: th_cabin_class_code]
          CONTENT: "舱位规范编码"
        [TABLE_HEAD: th_cabin_class_name]
          CONTENT: "舱位名称"
        [TABLE_HEAD: th_cabin_rank]
          CONTENT: "舱位等级序"
        [TABLE_HEAD: th_status]
          CONTENT: "status"
    [TABLE_BODY: travel_cabin_class_table_body]
      [FOR: row in rows]
        [TABLE_ROW: travel_cabin_class_row]
          [TABLE_CELL: td_cabin_class_code]
            CONTENT: "{{row.cabin_class_code|}}"
          [TABLE_CELL: td_cabin_class_name]
            CONTENT: "{{row.cabin_class_name|}}"
          [TABLE_CELL: td_cabin_rank]
            CONTENT: "{{row.cabin_rank|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: travel_cabin_class_no_data]
      ATTR: Description("暂无舱位主数据（Travel 层，来源 OFBiz Enumeration）数据")
  [/IF]
