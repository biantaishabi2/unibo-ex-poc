[PAGE: travel_hotel_detail]
  ATTR: Title("TravelHotel 详情")

  [BREADCRUMB: travel_hotel_breadcrumb]
    [BREADCRUMB_LIST: travel_hotel_bc_list]
      [BREADCRUMB_ITEM: travel_hotel_bc_list_item]
        [BREADCRUMB_LINK: travel_hotel_bc_link]
          ATTR: Patch("/travel/travel_hotel")
          CONTENT: "TravelHotel 列表"
      [BREADCRUMB_SEPARATOR: travel_hotel_bc_sep]
      [BREADCRUMB_ITEM: travel_hotel_bc_current_item]
        [BREADCRUMB_PAGE: travel_hotel_bc_current]
          CONTENT: "{{record.hotel_code|详情}}"

  [SECTION: travel_hotel_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: travel_hotel_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: travel_hotel_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.hotel_code|}}"
      [BADGE: travel_hotel_status_badge]
        CONTENT: "{{record.status|}}"
    [FLEX: travel_hotel_actions]
      { Gap: 2 }
      [BUTTON: travel_hotel_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"

  [CARD: travel_hotel_info_card]
    [CARD_HEADER: travel_hotel_info_header]
      [CARD_TITLE: travel_hotel_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: travel_hotel_info_content]
      [IF: !editing]
        [GRID: travel_hotel_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_hotel_code]
            [TEXT: label_hotel_code]
              ATTR: Variant("muted")
              CONTENT: "酒店规范编码"
            [TEXT: value_hotel_code]
              CONTENT: "{{record.hotel_code|}}"
          [FLEX: field_hotel_name]
            [TEXT: label_hotel_name]
              ATTR: Variant("muted")
              CONTENT: "酒店名称"
            [TEXT: value_hotel_name]
              CONTENT: "{{record.hotel_name|}}"
          [FLEX: field_city_code]
            [TEXT: label_city_code]
              ATTR: Variant("muted")
              CONTENT: "城市编码冗余（便于兼容检索）"
            [TEXT: value_city_code]
              CONTENT: "{{record.city_code|}}"
          [FLEX: field_hotel_star]
            [TEXT: label_hotel_star]
              ATTR: Variant("muted")
              CONTENT: "酒店星级"
            [TEXT: value_hotel_star]
              CONTENT: "{{record.hotel_star|}}"
          [FLEX: field_status]
            [TEXT: label_status]
              ATTR: Variant("muted")
              CONTENT: "status"
            [BADGE: value_status]
              CONTENT: "{{record.status|}}"
      [ELSE]
        [FORM: travel_hotel_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: travel_hotel_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_hotel_code]
              ATTR: Name("hotel_code"), Label("酒店规范编码"), Placeholder("请输入酒店规范编码"), Required("true")
            [INPUT: form_hotel_name]
              ATTR: Name("hotel_name"), Label("酒店名称"), Placeholder("请输入酒店名称"), Required("true")
            [INPUT: form_city_code]
              ATTR: Name("city_code"), Label("城市编码冗余（便于兼容检索）"), Placeholder("请输入城市编码冗余（便于兼容检索）")
            [INPUT: form_hotel_star]
              ATTR: Name("hotel_star"), Label("酒店星级"), Placeholder("请输入酒店星级")
            [SELECT: form_status]
              ATTR: Name("status"), Label("status")
          [FLEX: travel_hotel_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: travel_hotel_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: travel_hotel_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
