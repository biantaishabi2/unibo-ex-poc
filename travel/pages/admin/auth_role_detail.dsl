[PAGE: auth_role_detail]
  META: Entity("TravelPolicy"), Domain("Travel")
  BIND: Fields("*")
  ATTR: Title("角色权限详情")

  [BREADCRUMB: auth_role_breadcrumb]
    [BREADCRUMB_LIST: auth_role_bc_list]
      [BREADCRUMB_ITEM: auth_role_bc_list_item]
        [BREADCRUMB_LINK: auth_role_bc_link]
          ATTR: Patch("/admin/auth_role")
          CONTENT: "角色权限列表"
      [BREADCRUMB_SEPARATOR: auth_role_bc_sep]
      [BREADCRUMB_ITEM: auth_role_bc_current_item]
        [BREADCRUMB_PAGE: auth_role_bc_current]
          CONTENT: "{{record.role_name|详情}}"

  [SECTION: auth_role_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: auth_role_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: auth_role_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.role_name|}}"
      [BADGE: auth_role_status_badge]
        CONTENT: "{{record.status|}}"
    [FLEX: auth_role_actions]
      { Gap: 2 }
      [BUTTON: auth_role_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"

  [CARD: auth_role_info_card]
    [CARD_HEADER: auth_role_info_header]
      [CARD_TITLE: auth_role_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: auth_role_info_content]
      [IF: !editing]
        [GRID: auth_role_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_role_name]
            [TEXT: label_role_name]
              ATTR: Variant("muted")
              CONTENT: "角色名称"
            [TEXT: value_role_name]
              CONTENT: "{{record.role_name|}}"
          [FLEX: field_role_code]
            [TEXT: label_role_code]
              ATTR: Variant("muted")
              CONTENT: "角色编码"
            [TEXT: value_role_code]
              CONTENT: "{{record.role_code|}}"
          [FLEX: field_description]
            [TEXT: label_description]
              ATTR: Variant("muted")
              CONTENT: "描述"
            [TEXT: value_description]
              CONTENT: "{{record.description|}}"
          [FLEX: field_members]
            [TEXT: label_members]
              ATTR: Variant("muted")
              CONTENT: "成员列表"
            [TEXT: value_members]
              CONTENT: "{{record.members|}}"
          [FLEX: field_permissions]
            [TEXT: label_permissions]
              ATTR: Variant("muted")
              CONTENT: "权限列表"
            [TEXT: value_permissions]
              CONTENT: "{{record.permissions|}}"
          [FLEX: field_status]
            [TEXT: label_status]
              ATTR: Variant("muted")
              CONTENT: "状态"
            [BADGE: value_status]
              CONTENT: "{{record.status|}}"
      [ELSE]
        [FORM: auth_role_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: auth_role_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_role_name]
              ATTR: Name("role_name"), Label("角色名称"), Placeholder("请输入角色名称"), Required("true")
            [INPUT: form_role_code]
              ATTR: Name("role_code"), Label("角色编码"), Placeholder("请输入角色编码"), Required("true")
            [INPUT: form_description]
              ATTR: Name("description"), Label("描述"), Placeholder("请输入描述")
            [INPUT: form_permissions]
              ATTR: Name("permissions"), Label("权限列表"), Placeholder("请配置权限列表")
            [SELECT: form_status]
              ATTR: Name("status"), Label("状态")
          [FLEX: auth_role_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: auth_role_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: auth_role_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
