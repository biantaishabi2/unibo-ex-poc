[PAGE: employee_detail]
  META: Entity("TravelOrder"), Domain("Travel")
  ATTR: Title("员工详情")

  [BREADCRUMB: employee_breadcrumb]
    [BREADCRUMB_LIST: employee_bc_list]
      [BREADCRUMB_ITEM: employee_bc_list_item]
        [BREADCRUMB_LINK: employee_bc_link]
          ATTR: Patch("/admin/employee")
          CONTENT: "员工管理列表"
      [BREADCRUMB_SEPARATOR: employee_bc_sep]
      [BREADCRUMB_ITEM: employee_bc_current_item]
        [BREADCRUMB_PAGE: employee_bc_current]
          CONTENT: "{{record.employee_name|详情}}"

  [SECTION: employee_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: employee_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: employee_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.employee_name|}}"
      [BADGE: employee_status_badge]
        CONTENT: "{{record.status|}}"
    [FLEX: employee_actions]
      { Gap: 2 }
      [BUTTON: employee_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"

  [CARD: employee_info_card]
    [CARD_HEADER: employee_info_header]
      [CARD_TITLE: employee_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: employee_info_content]
      [IF: !editing]
        [GRID: employee_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_employee_name]
            [TEXT: label_employee_name]
              ATTR: Variant("muted")
              CONTENT: "姓名"
            [TEXT: value_employee_name]
              CONTENT: "{{record.employee_name|}}"
          [FLEX: field_employee_code]
            [TEXT: label_employee_code]
              ATTR: Variant("muted")
              CONTENT: "员工编号"
            [TEXT: value_employee_code]
              CONTENT: "{{record.employee_code|}}"
          [FLEX: field_department]
            [TEXT: label_department]
              ATTR: Variant("muted")
              CONTENT: "部门"
            [TEXT: value_department]
              CONTENT: "{{record.department|}}"
          [FLEX: field_job_position]
            [TEXT: label_job_position]
              ATTR: Variant("muted")
              CONTENT: "职级"
            [TEXT: value_job_position]
              CONTENT: "{{record.job_position|}}"
          [FLEX: field_email]
            [TEXT: label_email]
              ATTR: Variant("muted")
              CONTENT: "邮箱"
            [TEXT: value_email]
              CONTENT: "{{record.email|}}"
          [FLEX: field_phone]
            [TEXT: label_phone]
              ATTR: Variant("muted")
              CONTENT: "手机号"
            [TEXT: value_phone]
              CONTENT: "{{record.phone|}}"
          [FLEX: field_id_card_no]
            [TEXT: label_id_card_no]
              ATTR: Variant("muted")
              CONTENT: "身份证号"
            [TEXT: value_id_card_no]
              CONTENT: "{{record.id_card_no|}}"
          [FLEX: field_entry_date]
            [TEXT: label_entry_date]
              ATTR: Variant("muted")
              CONTENT: "入职日期"
            [TEXT: value_entry_date]
              CONTENT: "{{record.entry_date|}}"
          [FLEX: field_status]
            [TEXT: label_status]
              ATTR: Variant("muted")
              CONTENT: "状态"
            [BADGE: value_status]
              CONTENT: "{{record.status|}}"
      [ELSE]
        [FORM: employee_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: employee_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_employee_name]
              ATTR: Name("employee_name"), Label("姓名"), Placeholder("请输入姓名"), Required("true")
            [INPUT: form_employee_code]
              ATTR: Name("employee_code"), Label("员工编号"), Placeholder("请输入员工编号"), Required("true")
            [SELECT: form_department]
              ATTR: Name("department"), Label("部门")
            [SELECT: form_job_position]
              ATTR: Name("job_position"), Label("职级")
            [INPUT: form_email]
              ATTR: Name("email"), Label("邮箱"), Placeholder("请输入邮箱")
            [INPUT: form_phone]
              ATTR: Name("phone"), Label("手机号"), Placeholder("请输入手机号")
            [INPUT: form_id_card_no]
              ATTR: Name("id_card_no"), Label("身份证号"), Placeholder("请输入身份证号")
            [INPUT: form_entry_date]
              ATTR: Name("entry_date"), Label("入职日期"), Placeholder("请选择入职日期")
            [SELECT: form_status]
              ATTR: Name("status"), Label("状态")
              BIND: Enum("TravelOrder", "status")
          [FLEX: employee_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: employee_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: employee_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
