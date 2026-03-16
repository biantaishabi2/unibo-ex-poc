[PAGE: job_position_detail]
  ATTR: Title("职级详情")

  [BREADCRUMB: job_position_breadcrumb]
    [BREADCRUMB_LIST: job_position_bc_list]
      [BREADCRUMB_ITEM: job_position_bc_list_item]
        [BREADCRUMB_LINK: job_position_bc_link]
          ATTR: Patch("/admin/job_position")
          CONTENT: "职级管理列表"
      [BREADCRUMB_SEPARATOR: job_position_bc_sep]
      [BREADCRUMB_ITEM: job_position_bc_current_item]
        [BREADCRUMB_PAGE: job_position_bc_current]
          CONTENT: "{{record.position_name|详情}}"

  [SECTION: job_position_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: job_position_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: job_position_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.position_name|}}"
      [BADGE: job_position_status_badge]
        CONTENT: "{{record.status|}}"
    [FLEX: job_position_actions]
      { Gap: 2 }
      [BUTTON: job_position_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"

  [CARD: job_position_info_card]
    [CARD_HEADER: job_position_info_header]
      [CARD_TITLE: job_position_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: job_position_info_content]
      [IF: !editing]
        [GRID: job_position_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_position_name]
            [TEXT: label_position_name]
              ATTR: Variant("muted")
              CONTENT: "职级名称"
            [TEXT: value_position_name]
              CONTENT: "{{record.position_name|}}"
          [FLEX: field_position_code]
            [TEXT: label_position_code]
              ATTR: Variant("muted")
              CONTENT: "职级编码"
            [TEXT: value_position_code]
              CONTENT: "{{record.position_code|}}"
          [FLEX: field_position_level]
            [TEXT: label_position_level]
              ATTR: Variant("muted")
              CONTENT: "级别"
            [TEXT: value_position_level]
              CONTENT: "{{record.position_level|}}"
          [FLEX: field_travel_level]
            [TEXT: label_travel_level]
              ATTR: Variant("muted")
              CONTENT: "差旅等级"
            [TEXT: value_travel_level]
              CONTENT: "{{record.travel_level|}}"
          [FLEX: field_description]
            [TEXT: label_description]
              ATTR: Variant("muted")
              CONTENT: "描述"
            [TEXT: value_description]
              CONTENT: "{{record.description|}}"
          [FLEX: field_status]
            [TEXT: label_status]
              ATTR: Variant("muted")
              CONTENT: "状态"
            [BADGE: value_status]
              CONTENT: "{{record.status|}}"
      [ELSE]
        [FORM: job_position_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: job_position_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_position_name]
              ATTR: Name("position_name"), Label("职级名称"), Placeholder("请输入职级名称"), Required("true")
            [INPUT: form_position_code]
              ATTR: Name("position_code"), Label("职级编码"), Placeholder("请输入职级编码"), Required("true")
            [INPUT: form_position_level]
              ATTR: Name("position_level"), Label("级别"), Placeholder("请输入级别")
            [INPUT: form_travel_level]
              ATTR: Name("travel_level"), Label("差旅等级"), Placeholder("请输入差旅等级")
            [INPUT: form_description]
              ATTR: Name("description"), Label("描述"), Placeholder("请输入描述")
            [SELECT: form_status]
              ATTR: Name("status"), Label("状态")
          [FLEX: job_position_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: job_position_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: job_position_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
