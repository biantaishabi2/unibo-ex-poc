[PAGE: department_detail]
  ATTR: Title("部门详情")

  [BREADCRUMB: department_breadcrumb]
    [BREADCRUMB_LIST: department_bc_list]
      [BREADCRUMB_ITEM: department_bc_list_item]
        [BREADCRUMB_LINK: department_bc_link]
          ATTR: Patch("/admin/department")
          CONTENT: "部门管理列表"
      [BREADCRUMB_SEPARATOR: department_bc_sep]
      [BREADCRUMB_ITEM: department_bc_current_item]
        [BREADCRUMB_PAGE: department_bc_current]
          CONTENT: "{{record.department_name|详情}}"

  [SECTION: department_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: department_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: department_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.department_name|}}"
      [BADGE: department_status_badge]
        CONTENT: "{{record.status|}}"
    [FLEX: department_actions]
      { Gap: 2 }
      [BUTTON: department_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"

  [CARD: department_info_card]
    [CARD_HEADER: department_info_header]
      [CARD_TITLE: department_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: department_info_content]
      [IF: !editing]
        [GRID: department_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_department_name]
            [TEXT: label_department_name]
              ATTR: Variant("muted")
              CONTENT: "部门名称"
            [TEXT: value_department_name]
              CONTENT: "{{record.department_name|}}"
          [FLEX: field_department_code]
            [TEXT: label_department_code]
              ATTR: Variant("muted")
              CONTENT: "部门编码"
            [TEXT: value_department_code]
              CONTENT: "{{record.department_code|}}"
          [FLEX: field_parent_department]
            [TEXT: label_parent_department]
              ATTR: Variant("muted")
              CONTENT: "上级部门"
            [TEXT: value_parent_department]
              CONTENT: "{{record.parent_department|}}"
          [FLEX: field_manager_name]
            [TEXT: label_manager_name]
              ATTR: Variant("muted")
              CONTENT: "负责人"
            [TEXT: value_manager_name]
              CONTENT: "{{record.manager_name|}}"
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
          [FLEX: field_created_at]
            [TEXT: label_created_at]
              ATTR: Variant("muted")
              CONTENT: "创建时间"
            [TEXT: value_created_at]
              CONTENT: "{{record.created_at|}}"
      [ELSE]
        [FORM: department_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: department_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_department_name]
              ATTR: Name("department_name"), Label("部门名称"), Placeholder("请输入部门名称"), Required("true")
            [INPUT: form_department_code]
              ATTR: Name("department_code"), Label("部门编码"), Placeholder("请输入部门编码"), Required("true")
            [INPUT: form_parent_department]
              ATTR: Name("parent_department"), Label("上级部门"), Placeholder("请输入上级部门")
            [INPUT: form_manager_name]
              ATTR: Name("manager_name"), Label("负责人"), Placeholder("请输入负责人")
            [INPUT: form_description]
              ATTR: Name("description"), Label("描述"), Placeholder("请输入描述")
            [SELECT: form_status]
              ATTR: Name("status"), Label("状态")
          [FLEX: department_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: department_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: department_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
