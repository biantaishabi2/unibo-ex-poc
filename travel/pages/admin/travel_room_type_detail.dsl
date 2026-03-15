[PAGE: travel_room_type_detail]
  ATTR: Title("TravelRoomType 详情")

  [BREADCRUMB: travel_room_type_breadcrumb]
    [BREADCRUMB_LIST: travel_room_type_bc_list]
      [BREADCRUMB_ITEM: travel_room_type_bc_list_item]
        [BREADCRUMB_LINK: travel_room_type_bc_link]
          ATTR: Patch("/travel/travel_room_type")
          CONTENT: "TravelRoomType 列表"
      [BREADCRUMB_SEPARATOR: travel_room_type_bc_sep]
      [BREADCRUMB_ITEM: travel_room_type_bc_current_item]
        [BREADCRUMB_PAGE: travel_room_type_bc_current]
          CONTENT: "{{record.room_type_code|详情}}"

  [SECTION: travel_room_type_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: travel_room_type_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: travel_room_type_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.room_type_code|}}"
      [BADGE: travel_room_type_status_badge]
        CONTENT: "{{record.status|}}"
    [FLEX: travel_room_type_actions]
      { Gap: 2 }
      [BUTTON: travel_room_type_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"

  [CARD: travel_room_type_info_card]
    [CARD_HEADER: travel_room_type_info_header]
      [CARD_TITLE: travel_room_type_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: travel_room_type_info_content]
      [IF: !editing]
        [GRID: travel_room_type_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_room_type_code]
            [TEXT: label_room_type_code]
              ATTR: Variant("muted")
              CONTENT: "房型规范编码"
            [TEXT: value_room_type_code]
              CONTENT: "{{record.room_type_code|}}"
          [FLEX: field_room_type_name]
            [TEXT: label_room_type_name]
              ATTR: Variant("muted")
              CONTENT: "房型名称"
            [TEXT: value_room_type_name]
              CONTENT: "{{record.room_type_name|}}"
          [FLEX: field_hotel_code]
            [TEXT: label_hotel_code]
              ATTR: Variant("muted")
              CONTENT: "酒店编码冗余（便于兼容检索）"
            [TEXT: value_hotel_code]
              CONTENT: "{{record.hotel_code|}}"
          [FLEX: field_bed_type]
            [TEXT: label_bed_type]
              ATTR: Variant("muted")
              CONTENT: "床型"
            [TEXT: value_bed_type]
              CONTENT: "{{record.bed_type|}}"
          [FLEX: field_status]
            [TEXT: label_status]
              ATTR: Variant("muted")
              CONTENT: "status"
            [BADGE: value_status]
              CONTENT: "{{record.status|}}"
      [ELSE]
        [FORM: travel_room_type_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: travel_room_type_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_room_type_code]
              ATTR: Name("room_type_code"), Label("房型规范编码"), Placeholder("请输入房型规范编码"), Required("true")
            [INPUT: form_room_type_name]
              ATTR: Name("room_type_name"), Label("房型名称"), Placeholder("请输入房型名称"), Required("true")
            [INPUT: form_hotel_code]
              ATTR: Name("hotel_code"), Label("酒店编码冗余（便于兼容检索）"), Placeholder("请输入酒店编码冗余（便于兼容检索）")
            [INPUT: form_bed_type]
              ATTR: Name("bed_type"), Label("床型"), Placeholder("请输入床型")
            [SELECT: form_status]
              ATTR: Name("status"), Label("status")
          [FLEX: travel_room_type_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: travel_room_type_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: travel_room_type_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
