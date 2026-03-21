[PAGE: travel_airline_detail]
  META: Entity("TravelAirline"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("TravelAirline 详情")

  [BREADCRUMB: travel_airline_breadcrumb]
    [BREADCRUMB_LIST: travel_airline_bc_list]
      [BREADCRUMB_ITEM: travel_airline_bc_list_item]
        [BREADCRUMB_LINK: travel_airline_bc_link]
          ATTR: Patch("/travel/travel_airline")
          CONTENT: "TravelAirline 列表"
      [BREADCRUMB_SEPARATOR: travel_airline_bc_sep]
      [BREADCRUMB_ITEM: travel_airline_bc_current_item]
        [BREADCRUMB_PAGE: travel_airline_bc_current]
          CONTENT: "{{record.airline_code|详情}}"

  [SECTION: travel_airline_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: travel_airline_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: travel_airline_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.airline_code|}}"
      [BADGE: travel_airline_status_badge]
        CONTENT: "{{record.status|}}"
    [FLEX: travel_airline_actions]
      { Gap: 2 }
      [BUTTON: travel_airline_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"

  [CARD: travel_airline_info_card]
    [CARD_HEADER: travel_airline_info_header]
      [CARD_TITLE: travel_airline_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: travel_airline_info_content]
      [IF: !editing]
        [GRID: travel_airline_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_airline_code]
            [TEXT: label_airline_code]
              ATTR: Variant("muted")
              CONTENT: "航司规范编码"
            [TEXT: value_airline_code]
              CONTENT: "{{record.airline_code|}}"
          [FLEX: field_airline_name]
            [TEXT: label_airline_name]
              ATTR: Variant("muted")
              CONTENT: "航司名称"
            [TEXT: value_airline_name]
              CONTENT: "{{record.airline_name|}}"
          [FLEX: field_iata_code]
            [TEXT: label_iata_code]
              ATTR: Variant("muted")
              CONTENT: "IATA 二字码"
            [TEXT: value_iata_code]
              CONTENT: "{{record.iata_code|}}"
          [FLEX: field_icao_code]
            [TEXT: label_icao_code]
              ATTR: Variant("muted")
              CONTENT: "ICAO 三字码"
            [TEXT: value_icao_code]
              CONTENT: "{{record.icao_code|}}"
          [FLEX: field_status]
            [TEXT: label_status]
              ATTR: Variant("muted")
              CONTENT: "status"
            [BADGE: value_status]
              CONTENT: "{{record.status|}}"
      [ELSE]
        [FORM: travel_airline_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: travel_airline_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_airline_code]
              ATTR: Name("airline_code"), Label("航司规范编码"), Placeholder("请输入航司规范编码"), Required("true")
            [INPUT: form_airline_name]
              ATTR: Name("airline_name"), Label("航司名称"), Placeholder("请输入航司名称"), Required("true")
            [INPUT: form_iata_code]
              ATTR: Name("iata_code"), Label("IATA 二字码"), Placeholder("请输入IATA 二字码")
            [INPUT: form_icao_code]
              ATTR: Name("icao_code"), Label("ICAO 三字码"), Placeholder("请输入ICAO 三字码")
            [SELECT: form_status]
              ATTR: Name("status"), Label("status")
          [FLEX: travel_airline_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: travel_airline_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: travel_airline_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
