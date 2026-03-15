[PAGE: pricing_rule]
  ATTR: Title("定价规则配置")

  [SECTION: toolbar_section]
    [FLEX: toolbar]
      { Justify: "Between", Align: "Center" }
      [TEXT: page_title]
        ATTR: Variant("h3"), Weight("bold")
        CONTENT: "定价规则配置"
      [BUTTON: create_btn]
        ATTR: Variant("primary"), Click("open_dialog:create_dialog")
        CONTENT: "新建规则"

  [SECTION: rule_table_section]
    [CARD: rule_table_card]
      [CARD_CONTENT: rule_table_content]
        [STACK: rule_list]
          { Gap: 0 }
          [FLEX: table_header]
            { Justify: "Between", Align: "Center" }
            [TEXT: col_product_type]
              ATTR: Variant("caption"), Weight("bold")
              CONTENT: "产品类型"
            [TEXT: col_supplier]
              ATTR: Variant("caption"), Weight("bold")
              CONTENT: "供应商编码"
            [TEXT: col_markup]
              ATTR: Variant("caption"), Weight("bold")
              CONTENT: "加价率"
            [TEXT: col_status]
              ATTR: Variant("caption"), Weight("bold")
              CONTENT: "状态"
            [TEXT: col_actions]
              ATTR: Variant("caption"), Weight("bold")
              CONTENT: "操作"
          [SEPARATOR: table_sep]
          [FOR: item in pricing_rules]
            [FLEX: rule_row]
              { Justify: "Between", Align: "Center" }
              [BADGE: product_type_badge]
                ATTR: Variant("secondary")
                CONTENT: "{{item.product_type|}}"
              [TEXT: supplier_code]
                CONTENT: "{{item.supplier_code|}}"
              [TEXT: markup_rate]
                CONTENT: "{{item.markup_rate|}}"
              [BADGE: status_badge]
                ATTR: Variant("outline")
                CONTENT: "{{item.status|}}"
              [FLEX: row_actions]
                { Gap: 1 }
                [BUTTON: save_btn]
                  ATTR: Variant("outline"), Size("sm"), Click("update")
                  CONTENT: "保存"
                [BUTTON: delete_btn]
                  ATTR: Variant("destructive"), Size("sm"), Click("destroy")
                  CONTENT: "删除"
          [/FOR]

  [SECTION: dialog_section]
    [DIALOG: create_dialog]
      ATTR: Title("新建规则")
      [STACK: create_form]
        { Gap: 3 }
        [SELECT: product_type_select]
          ATTR: Label("产品类型"), Name("product_type"), Required("true")
          CONTENT: "酒店:hotel,机票:flight,火车票:train"
        [INPUT: supplier_code_input]
          ATTR: Label("供应商编码"), Placeholder("请输入供应商编码"), Bind("form.supplier_code"), Required("true")
        [INPUT: markup_rate_input]
          ATTR: Label("加价率"), Placeholder("例如 0.15 表示加价 15%"), Bind("form.markup_rate"), Type("number"), Required("true")
        [SELECT: status_select]
          ATTR: Label("状态"), Name("status"), Required("true")
          CONTENT: "启用:active,停用:inactive"
        [BUTTON: submit_create_btn]
          ATTR: Variant("primary"), Click("create")
          CONTENT: "创建"
