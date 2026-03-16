[PAGE: approval_category_config]
  ATTR: Title("审批规则配置")

  [SECTION: approval_category_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: approval_category_title]
      ATTR: Variant("title")
      CONTENT: "审批规则配置"
    [BUTTON: approval_category_create_btn]
      ATTR: Variant("primary"), Click("create_category")
      CONTENT: "新建"

  [FLEX: category_list]
    { Direction: "Column" }
    [FOR: category in categories]
      [CARD: category_card]
        [CARD_HEADER: category_card_header]
          [FLEX: category_card_header_row]
            { Direction: "Row", Justify: "Between", Align: "Center" }
            [FLEX: category_card_title_group]
              { Gap: 3, Align: "Center" }
              [TEXT: category_name_text]
                ATTR: Variant("subtitle")
                CONTENT: "{{category.category_name|}}"
              [BADGE: category_trigger_badge]
                CONTENT: "{{category.trigger_condition|}}"
            [FLEX: category_card_actions]
              { Gap: 2 }
              [BUTTON: category_expand_btn]
                ATTR: Variant("ghost"), Click("toggle_expand")
                CONTENT: "展开/编辑"
        [CARD_CONTENT: category_card_content]
          [TEXT: category_approval_chain_summary]
            ATTR: Variant("muted")
            CONTENT: "{{category.approval_chain_summary|}}"
    [/FOR]

  [IF: editing]
    [CARD: edit_card]
      [CARD_HEADER: edit_card_header]
        [CARD_TITLE: edit_card_title]
          CONTENT: "编辑审批规则"
      [CARD_CONTENT: edit_card_content]
        [FORM: category_edit_form]
          ATTR: Submit("category_form_submit"), Change("form_change")
          [GRID: category_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_category_name]
              ATTR: Name("category_name"), Label("规则名称"), Placeholder("请输入规则名称"), Required("true")
            [SELECT: form_trigger_condition]
              ATTR: Name("trigger_condition"), Label("触发条件")
          [TEXT: approval_chain_label]
            ATTR: Variant("subtitle")
            CONTENT: "审批链配置"
          [FLEX: approval_chain_nodes]
            { Direction: "Column" }
            [FOR: node in approval_nodes]
              [FLEX: approval_node_row]
                { Gap: 3, Align: "Center" }
                [SELECT: node_role_select]
                  ATTR: Name("node_role"), Label("审批角色")
                [INPUT: node_condition_input]
                  ATTR: Name("node_condition"), Label("触发条件"), Placeholder("请输入条件（可选）")
                [BUTTON: node_remove_btn]
                  ATTR: Variant("destructive"), Click("remove_node")
                  CONTENT: "删除"
            [/FOR]
          [BUTTON: add_node_btn]
            ATTR: Variant("secondary"), Click("add_approval_node")
            CONTENT: "添加审批节点"
          [FLEX: category_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: category_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: category_save_btn]
              ATTR: Variant("primary"), Click("category_form_submit")
              CONTENT: "保存"
  [/IF]
