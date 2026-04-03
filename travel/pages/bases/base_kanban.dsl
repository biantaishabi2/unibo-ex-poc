[PAGE: base_kanban]
  ATTR: Title("看板"), FullHeight(true)

  [SECTION: kanban_header]
    [FLEX: header_bar]
      { Direction: "row", Justify: "between", Align: "center", Class: "px-6 py-4" }
      [STACK: page_meta]
        BIND: EntityMeta()
      [FLEX: header_actions]
        { Direction: "row", Gap: 2 }
        [BUTTON: create_btn]
          BIND: Action("create")

  [SECTION: kanban_filter]
    [FLEX: filter_fields]
      BIND: Filters("read")

  [SECTION: kanban_board]
    [FLEX: board_columns]
      { Direction: "row", Gap: 4, Class: "overflow-x-auto p-4 min-h-[500px]" }
      [STACK: state_columns]
        BIND: States()

  [SECTION: kanban_footer]
    [FLEX: footer_bar]
      { Direction: "row", Justify: "between", Class: "px-6 py-3" }
      [TEXT: total_count]
        CONTENT: "{{total_count|0}} 条记录"
