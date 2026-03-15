[PAGE: travel_static_code_mapping_detail]
  ATTR: Title("TravelStaticCodeMapping 详情")

  [BREADCRUMB: travel_static_code_mapping_breadcrumb]
    [BREADCRUMB_LIST: travel_static_code_mapping_bc_list]
      [BREADCRUMB_ITEM: travel_static_code_mapping_bc_list_item]
        [BREADCRUMB_LINK: travel_static_code_mapping_bc_link]
          ATTR: Patch("/travel/travel_static_code_mapping")
          CONTENT: "TravelStaticCodeMapping 列表"
      [BREADCRUMB_SEPARATOR: travel_static_code_mapping_bc_sep]
      [BREADCRUMB_ITEM: travel_static_code_mapping_bc_current_item]
        [BREADCRUMB_PAGE: travel_static_code_mapping_bc_current]
          CONTENT: "{{record.supplier_code|详情}}"

  [SECTION: travel_static_code_mapping_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: travel_static_code_mapping_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: travel_static_code_mapping_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.supplier_code|}}"
      [BADGE: travel_static_code_mapping_status_badge]
        CONTENT: "{{record.status|}}"
    [FLEX: travel_static_code_mapping_actions]
      { Gap: 2 }
      [BUTTON: travel_static_code_mapping_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"

  [CARD: travel_static_code_mapping_info_card]
    [CARD_HEADER: travel_static_code_mapping_info_header]
      [CARD_TITLE: travel_static_code_mapping_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: travel_static_code_mapping_info_content]
      [IF: !editing]
        [GRID: travel_static_code_mapping_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_supplier_code]
            [TEXT: label_supplier_code]
              ATTR: Variant("muted")
              CONTENT: "供应商编码"
            [TEXT: value_supplier_code]
              CONTENT: "{{record.supplier_code|}}"
          [FLEX: field_object_type]
            [TEXT: label_object_type]
              ATTR: Variant("muted")
              CONTENT: "主数据对象类型"
            [BADGE: value_object_type]
              CONTENT: "{{record.object_type|}}"
          [FLEX: field_canonical_entity]
            [TEXT: label_canonical_entity]
              ATTR: Variant("muted")
              CONTENT: "Travel 实体名"
            [TEXT: value_canonical_entity]
              CONTENT: "{{record.canonical_entity|}}"
          [FLEX: field_canonical_id]
            [TEXT: label_canonical_id]
              ATTR: Variant("muted")
              CONTENT: "Travel 实体 ID"
            [TEXT: value_canonical_id]
              CONTENT: "{{record.canonical_id|}}"
          [FLEX: field_external_code]
            [TEXT: label_external_code]
              ATTR: Variant("muted")
              CONTENT: "供应商侧编码"
            [TEXT: value_external_code]
              CONTENT: "{{record.external_code|}}"
          [FLEX: field_external_name]
            [TEXT: label_external_name]
              ATTR: Variant("muted")
              CONTENT: "供应商侧名称"
            [TEXT: value_external_name]
              CONTENT: "{{record.external_name|}}"
          [FLEX: field_status]
            [TEXT: label_status]
              ATTR: Variant("muted")
              CONTENT: "status"
            [BADGE: value_status]
              CONTENT: "{{record.status|}}"
      [ELSE]
        [FORM: travel_static_code_mapping_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: travel_static_code_mapping_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_supplier_code]
              ATTR: Name("supplier_code"), Label("供应商编码"), Placeholder("请输入供应商编码"), Required("true")
            [SELECT: form_object_type]
              ATTR: Name("object_type"), Label("主数据对象类型"), Required("true")
            [INPUT: form_canonical_entity]
              ATTR: Name("canonical_entity"), Label("Travel 实体名"), Placeholder("请输入Travel 实体名"), Required("true")
            [INPUT: form_canonical_id]
              ATTR: Name("canonical_id"), Label("Travel 实体 ID"), Placeholder("请输入Travel 实体 ID"), Required("true")
            [INPUT: form_external_code]
              ATTR: Name("external_code"), Label("供应商侧编码"), Placeholder("请输入供应商侧编码"), Required("true")
            [INPUT: form_external_name]
              ATTR: Name("external_name"), Label("供应商侧名称"), Placeholder("请输入供应商侧名称")
            [SELECT: form_status]
              ATTR: Name("status"), Label("status")
          [FLEX: travel_static_code_mapping_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: travel_static_code_mapping_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: travel_static_code_mapping_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
