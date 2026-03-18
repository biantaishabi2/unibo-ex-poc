[PAGE: scheduling_constraint_list]
  EXTENDS: base_list_report
  META: Entity("SchedulingConstraint"), Domain("Scheduling")

  OVERRIDE: section("header")
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [TEXT: page_title]
        ATTR: Variant("title")
        CONTENT: "{{page_title|排班约束配置}}"
      [FLEX: toolbar_actions]
        { Gap: 2 }
        [BUTTON: create_btn]
          ATTR: Variant("primary"), Click("navigate_create")
          CONTENT: "新建约束"
        [BUTTON: back_btn]
          ATTR: Variant("secondary"), Click("navigate_back")
          CONTENT: "返回周期详情"

  OVERRIDE: section("filter_section")
    [CARD: filter_card]
      [CARD_CONTENT: filter_content]
        [FLEX: filter_row]
          { Gap: 4, Align: "Center" }
          [SELECT: filter_constraint_type]
            ATTR: Name("constraint_type"), Label("约束类型")
            BIND: Enum("constraint_type")
          [SELECT: filter_category]
            ATTR: Name("category"), Label("规则类别")
            BIND: Enum("category")
          [SELECT: filter_enabled]
            ATTR: Name("enabled"), Label("状态")
            BIND: Enum("enabled")
          [BUTTON: filter_submit]
            ATTR: Variant("secondary"), Click("filter_submit")
            CONTENT: "查询"

  OVERRIDE: section("table_section")
    [TABLE: constraint_table]
      [TABLE_HEADER: constraint_header]
        [TABLE_ROW: header_row]
          [TABLE_HEAD: th_name]
            CONTENT: "规则名称"
          [TABLE_HEAD: th_type]
            CONTENT: "约束类型"
          [TABLE_HEAD: th_category]
            CONTENT: "规则类别"
          [TABLE_HEAD: th_weight]
            CONTENT: "权重"
          [TABLE_HEAD: th_enabled]
            CONTENT: "启用"
          [TABLE_HEAD: th_notes]
            CONTENT: "备注"
          [TABLE_HEAD: th_actions]
            CONTENT: "操作"
      [TABLE_BODY: constraint_body]
        [FOR: row in rows]
          [TABLE_ROW: constraint_row]
            [TABLE_CELL: td_name]
              CONTENT: "{{row.name|}}"
            [TABLE_CELL: td_type]
              [BADGE: type_badge]
                BIND: Enum("constraint_type")
                CONTENT: "{{row.constraint_type|}}"
            [TABLE_CELL: td_category]
              [BADGE: category_badge]
                ATTR: Variant("secondary")
                BIND: Enum("category")
                CONTENT: "{{row.category|}}"
            [TABLE_CELL: td_weight]
              CONTENT: "{{row.weight|}}"
            [TABLE_CELL: td_enabled]
              [BADGE: enabled_badge]
                BIND: Enum("enabled")
                CONTENT: "{{row.enabled|}}"
            [TABLE_CELL: td_notes]
              CONTENT: "{{row.notes|}}"
            [TABLE_CELL: td_actions]
              [FLEX: row_actions]
                { Gap: 1 }
                [BUTTON: edit_btn]
                  ATTR: Variant("outline"), Size("sm"), Click("navigate_edit")
                  CONTENT: "编辑"
                [BUTTON: toggle_btn]
                  ATTR: Variant("outline"), Size("sm"), Click("toggle_enabled")
                  CONTENT: "切换"
                [BUTTON: delete_btn]
                  ATTR: Variant("destructive"), Size("sm"), Click("action_destroy")
                  CONTENT: "删除"
        [/FOR]
