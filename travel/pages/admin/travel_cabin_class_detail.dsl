[PAGE: travel_cabin_class_detail]
  ATTR: Title("TravelCabinClass 详情")

  [BREADCRUMB: travel_cabin_class_breadcrumb]
    [BREADCRUMB_LIST: travel_cabin_class_bc_list]
      [BREADCRUMB_ITEM: travel_cabin_class_bc_list_item]
        [BREADCRUMB_LINK: travel_cabin_class_bc_link]
          ATTR: Patch("/travel/travel_cabin_class")
          CONTENT: "TravelCabinClass 列表"
      [BREADCRUMB_SEPARATOR: travel_cabin_class_bc_sep]
      [BREADCRUMB_ITEM: travel_cabin_class_bc_current_item]
        [BREADCRUMB_PAGE: travel_cabin_class_bc_current]
          CONTENT: "{{record.cabin_class_code|详情}}"

  [SECTION: travel_cabin_class_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: travel_cabin_class_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: travel_cabin_class_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.cabin_class_code|}}"
      [BADGE: travel_cabin_class_status_badge]
        CONTENT: "{{record.status|}}"
    [FLEX: travel_cabin_class_actions]
      { Gap: 2 }
      [BUTTON: travel_cabin_class_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"

  [CARD: travel_cabin_class_info_card]
    [CARD_HEADER: travel_cabin_class_info_header]
      [CARD_TITLE: travel_cabin_class_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: travel_cabin_class_info_content]
      [IF: !editing]
        [GRID: travel_cabin_class_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_cabin_class_code]
            [TEXT: label_cabin_class_code]
              ATTR: Variant("muted")
              CONTENT: "舱位规范编码"
            [TEXT: value_cabin_class_code]
              CONTENT: "{{record.cabin_class_code|}}"
          [FLEX: field_cabin_class_name]
            [TEXT: label_cabin_class_name]
              ATTR: Variant("muted")
              CONTENT: "舱位名称"
            [TEXT: value_cabin_class_name]
              CONTENT: "{{record.cabin_class_name|}}"
          [FLEX: field_cabin_rank]
            [TEXT: label_cabin_rank]
              ATTR: Variant("muted")
              CONTENT: "舱位等级序"
            [TEXT: value_cabin_rank]
              CONTENT: "{{record.cabin_rank|}}"
          [FLEX: field_status]
            [TEXT: label_status]
              ATTR: Variant("muted")
              CONTENT: "status"
            [BADGE: value_status]
              CONTENT: "{{record.status|}}"
      [ELSE]
        [FORM: travel_cabin_class_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: travel_cabin_class_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_cabin_class_code]
              ATTR: Name("cabin_class_code"), Label("舱位规范编码"), Placeholder("请输入舱位规范编码"), Required("true")
            [INPUT: form_cabin_class_name]
              ATTR: Name("cabin_class_name"), Label("舱位名称"), Placeholder("请输入舱位名称"), Required("true")
            [INPUT: form_cabin_rank]
              ATTR: Name("cabin_rank"), Label("舱位等级序"), Placeholder("请输入舱位等级序")
            [SELECT: form_status]
              ATTR: Name("status"), Label("status")
          [FLEX: travel_cabin_class_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: travel_cabin_class_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: travel_cabin_class_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
