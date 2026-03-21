[PAGE: travel_room_type_list]
  META: Entity("TravelRoomType"), Domain("Travel")
  ATTR: Title("TravelRoomType 列表")

  [SECTION: travel_room_type_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: travel_room_type_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TravelRoomType 列表}}"
    [BUTTON: travel_room_type_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: travel_room_type_filter_card]
    [CARD_CONTENT: travel_room_type_filter_content]
      [FLEX: travel_room_type_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_status]
          ATTR: Name("status"), Label("status")
        [BUTTON: travel_room_type_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: travel_room_type_table]
    BIND: Fields("*")
    [TABLE_HEADER: travel_room_type_table_header]
      [TABLE_ROW: travel_room_type_header_row]
        [TABLE_HEAD: th_room_type_code]
          CONTENT: "房型规范编码"
        [TABLE_HEAD: th_room_type_name]
          CONTENT: "房型名称"
        [TABLE_HEAD: th_hotel_code]
          CONTENT: "酒店编码冗余（便于兼容检索）"
        [TABLE_HEAD: th_bed_type]
          CONTENT: "床型"
        [TABLE_HEAD: th_status]
          CONTENT: "status"
    [TABLE_BODY: travel_room_type_table_body]
      [FOR: row in rows]
        [TABLE_ROW: travel_room_type_row]
          [TABLE_CELL: td_room_type_code]
            CONTENT: "{{row.room_type_code|}}"
          [TABLE_CELL: td_room_type_name]
            CONTENT: "{{row.room_type_name|}}"
          [TABLE_CELL: td_hotel_code]
            CONTENT: "{{row.hotel_code|}}"
          [TABLE_CELL: td_bed_type]
            CONTENT: "{{row.bed_type|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: travel_room_type_no_data]
      ATTR: Description("暂无酒店房型主数据（Travel 层，来源 OFBiz ProductFeature）数据")
  [/IF]
