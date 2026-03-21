[PAGE: travel_airline_list]
  META: Entity("TravelAirline"), Domain("Travel")
  ATTR: Title("TravelAirline 列表")

  [SECTION: travel_airline_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: travel_airline_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TravelAirline 列表}}"
    [BUTTON: travel_airline_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: travel_airline_filter_card]
    [CARD_CONTENT: travel_airline_filter_content]
      [FLEX: travel_airline_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_status]
          ATTR: Name("status"), Label("status")
        [BUTTON: travel_airline_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: travel_airline_table]
    BIND: Fields("*")
    [TABLE_HEADER: travel_airline_table_header]
      [TABLE_ROW: travel_airline_header_row]
        [TABLE_HEAD: th_airline_code]
          CONTENT: "航司规范编码"
        [TABLE_HEAD: th_airline_name]
          CONTENT: "航司名称"
        [TABLE_HEAD: th_iata_code]
          CONTENT: "IATA 二字码"
        [TABLE_HEAD: th_icao_code]
          CONTENT: "ICAO 三字码"
        [TABLE_HEAD: th_status]
          CONTENT: "status"
    [TABLE_BODY: travel_airline_table_body]
      [FOR: row in rows]
        [TABLE_ROW: travel_airline_row]
          [TABLE_CELL: td_airline_code]
            CONTENT: "{{row.airline_code|}}"
          [TABLE_CELL: td_airline_name]
            CONTENT: "{{row.airline_name|}}"
          [TABLE_CELL: td_iata_code]
            CONTENT: "{{row.iata_code|}}"
          [TABLE_CELL: td_icao_code]
            CONTENT: "{{row.icao_code|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: travel_airline_no_data]
      ATTR: Description("暂无航司主数据（Travel 层，来源 OFBiz PartyGroup）数据")
  [/IF]
