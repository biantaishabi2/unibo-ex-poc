[PAGE: travel_hotel_list]
  META: Entity("TravelHotel"), Domain("Travel")
  ATTR: Title("TravelHotel 列表")

  [SECTION: travel_hotel_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: travel_hotel_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TravelHotel 列表}}"
    [BUTTON: travel_hotel_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: travel_hotel_filter_card]
    [CARD_CONTENT: travel_hotel_filter_content]
      [FLEX: travel_hotel_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_status]
          ATTR: Name("status"), Label("status")
        [BUTTON: travel_hotel_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: travel_hotel_table]
    BIND: Fields("*")
    [TABLE_HEADER: travel_hotel_table_header]
      [TABLE_ROW: travel_hotel_header_row]
        [TABLE_HEAD: th_hotel_code]
          CONTENT: "酒店规范编码"
        [TABLE_HEAD: th_hotel_name]
          CONTENT: "酒店名称"
        [TABLE_HEAD: th_city_code]
          CONTENT: "城市编码冗余（便于兼容检索）"
        [TABLE_HEAD: th_hotel_star]
          CONTENT: "酒店星级"
        [TABLE_HEAD: th_status]
          CONTENT: "status"
    [TABLE_BODY: travel_hotel_table_body]
      [FOR: row in rows]
        [TABLE_ROW: travel_hotel_row]
          [TABLE_CELL: td_hotel_code]
            CONTENT: "{{row.hotel_code|}}"
          [TABLE_CELL: td_hotel_name]
            CONTENT: "{{row.hotel_name|}}"
          [TABLE_CELL: td_city_code]
            CONTENT: "{{row.city_code|}}"
          [TABLE_CELL: td_hotel_star]
            CONTENT: "{{row.hotel_star|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: travel_hotel_no_data]
      ATTR: Description("暂无酒店主数据（Travel 层，来源 OFBiz Product）数据")
  [/IF]
