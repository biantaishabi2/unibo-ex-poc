[PAGE: base_list]
  ATTR: Title("列表")
  [SECTION: header]
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [STACK: page_meta]
        BIND: EntityMeta()
      [BUTTON: create_btn]
        BIND: Action("create")
        ATTR: Variant("primary"), Click("navigate_create")
        CONTENT: "新建"
  [SECTION: view_tabs]
    [TABS: view_selector]
      ATTR: DefaultValue("all")
      [TABS_LIST: view_tab_list]
        [TABS_TRIGGER: trigger_all]
          ATTR: Value("all")
          CONTENT: "全部"
  [SECTION: filter_section]
    [CARD: filter_card]
      [CARD_CONTENT: filter_content]
        [FLEX: filter_row]
          { Gap: 4, Align: "Center" }
          [STACK: filter_fields]
            BIND: Filters("read")
          [BUTTON: filter_submit]
            ATTR: Variant("secondary"), Click("filter_submit")
            CONTENT: "查询"
  [SECTION: table_section]
    [TABLE: data_table]
      [TABLE_HEADER: data_header]
        [TABLE_ROW: header_row]
          [GRID: field_headers]
            BIND: Fields("*")
      [TABLE_BODY: data_body]
        [GRID: field_values]
          BIND: Fields("*")
  [SECTION: empty_section]
    [IF: rows_empty]
      [EMPTY_STATE: no_data]
        ATTR: Description("暂无数据")
    [/IF]
  [SECTION: footer]
    [FLEX: pagination_bar]
      BIND: Pagination()

  # ── 变体: SelectionMode("multi") ──────────────────────────
  [SECTION: header@multi]
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [TEXT: page_title]
        ATTR: Variant("title")
        CONTENT: "{{page_title|批量操作}}"
      [FLEX: header_actions]
        { Gap: 2 }
        [BUTTON: select_all_btn]
          ATTR: Variant("secondary"), Click("select_all")
          CONTENT: "全选"
        [BUTTON: clear_selection_btn]
          ATTR: Variant("ghost"), Click("clear_selection")
          CONTENT: "清除选择"
  [SECTION: filter_section@multi]
    [CARD: action_card]
      [CARD_CONTENT: action_content]
        [FLEX: action_row]
          { Justify: "Between", Align: "Center" }
          [TEXT: selection_count]
            CONTENT: "{{selection_summary|已选择 0 项}}"
          [FLEX: bulk_buttons]
            { Gap: 2 }
            [SELECT: bulk_action]
              ATTR: Name("bulk_action"), Label("批量操作")
              CONTENT: "请选择操作:"
              CONTENT: "批量启用:enable"
              CONTENT: "批量禁用:disable"
              CONTENT: "批量删除:delete"
              CONTENT: "批量导出:export"
              CONTENT: "批量修改分类:change_category"
            [BUTTON: execute_btn]
              ATTR: Variant("primary"), Click("bulk_execute")
              CONTENT: "执行"
  [SECTION: table_section@multi]
    [TABLE: data_table]
      [TABLE_HEADER: data_header]
        [TABLE_ROW: header_row]
          [TABLE_HEAD: th_select]
            CONTENT: "选择"
          [GRID: field_headers]
            BIND: Fields("*")
      [TABLE_BODY: data_body]
        [FOR: row in rows]
          [TABLE_ROW: data_row]
            [TABLE_CELL: td_select]
              CONTENT: "{{row.selected|}}"
            [GRID: field_values]
              BIND: Fields("*")
        [/FOR]

  # ── 变体: FilterMode("search_only") ──────────────────────
  [SECTION: header@search_only]
    [STACK: search_header]
      { Gap: 3 }
      [TEXT: page_title]
        ATTR: Variant("title")
        CONTENT: "{{page_title|搜索}}"
      [FLEX: search_bar]
        { Gap: 2, Align: "Center" }
        [INPUT: search_input]
          ATTR: Name("keyword"), Placeholder("请输入搜索关键词..."), Required("true")
        [SELECT: search_scope]
          ATTR: Name("scope"), Label("搜索范围")
          CONTENT: "全部:all"
          CONTENT: "标题:title"
          CONTENT: "内容:content"
          CONTENT: "编码:code"
        [BUTTON: search_btn]
          ATTR: Variant("primary"), Click("search_execute")
          CONTENT: "搜索"
  [SECTION: filter_section@search_only]
    [FLEX: result_summary]
      { Justify: "Between", Align: "Center" }
      [TEXT: result_count]
        ATTR: Variant("body"), Color("muted")
        CONTENT: "{{result_summary|共 0 条结果}}"
      [FLEX: sort_options]
        { Gap: 2 }
        [SELECT: sort_by]
          ATTR: Name("sort_by"), Label("排序")
          CONTENT: "相关度:relevance"
          CONTENT: "最新:newest"
          CONTENT: "最早:oldest"

  # ── 变体: Display("card_grid") ────────────────────────────
  [SECTION: header@card_grid]
    [FLEX: shell_nav]
      { Justify: "Around" }
      [BUTTON: tab_home]
        ATTR: Variant("ghost"), Icon("house"), Click("navigate:/home")
        CONTENT: "首页"
      [BUTTON: tab_services]
        ATTR: Variant("ghost"), Icon("grid-2x2"), Click("navigate:/services")
        CONTENT: "服务"
      [BUTTON: tab_me]
        ATTR: Variant("ghost"), Icon("user-round"), Click("navigate:/me")
        CONTENT: "我的"
    [FLEX: filter_bar]
      { Gap: 2, PaddingX: 3, PaddingY: 2, Wrap: true }
      [INPUT: search_input]
        ATTR: Name("keyword"), Placeholder("搜索")
  [SECTION: table_section@card_grid]
    [GRID: result_grid]
      { Columns: 2, Gap: 3, Padding: 3 }
      [FOR: item in items]
        [CARD: item_card]
          ATTR: Click("navigate")
          [CARD_CONTENT: card_content]
            [TEXT: card_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "{{item.title|}}"
            [TEXT: card_desc]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{item.description|}}"
      [/FOR]
