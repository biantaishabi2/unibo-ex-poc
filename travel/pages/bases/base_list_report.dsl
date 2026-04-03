[PAGE: base_list]
  ATTR: Title("列表"), FullHeight(true), Padding(0), Variant("fit365-canvas")
  [SECTION: header]
    [CARD: header_shell]
      ATTR: Variant("fit365-shell"), ClassName("overflow-hidden")
      [CARD_CONTENT: header_shell_content]
        [STACK: header_stack]
          ATTR: Gap(0)
          [FLEX: header_bar]
            ATTR: ClassName("bg-[linear-gradient(90deg,var(--color-primary-dark-2)_0%,var(--color-primary-dark-1)_55%,var(--color-primary)_100%)] px-6 py-4 text-white"), Justify("Between"), Align("Center"), Wrap(true), Gap(3)
            [STACK: header_info]
              ATTR: Gap(2)
              [FLEX: header_highlights]
                ATTR: Gap(2), Wrap(true), Align("Center")
                [BADGE: list_mode_badge]
                  ATTR: Variant("secondary")
                  CONTENT: "企业数据视图"
                [TEXT: list_hint]
                  ATTR: Variant("caption")
                  CONTENT: "{{subtitle|筛选、摘要与分页默认成套呈现}}"
            [FLEX: header_actions]
              ATTR: Gap(2), Align("Center"), Wrap(true)
              [BADGE: list_sync_badge]
                ATTR: Variant("outline")
                CONTENT: "{{sync_status|今日已同步}}"
              [BUTTON: create_btn]
                BIND: Action("create")
                ATTR: Variant("primary")
          [STACK: header_body]
            ATTR: ClassName("space-y-6 px-6 py-6")
            [STACK: page_meta]
              BIND: EntityMeta()
            [CARD: overview_card]
              ATTR: Variant("fit365-soft")
              [CARD_CONTENT: overview_content]
                [FLEX: overview_row]
                  { Gap: 3, Wrap: true }
                  [STACK: overview_total]
                    { Gap: 1 }
                    [TEXT: overview_total_label]
                      ATTR: Variant("caption"), Color("muted")
                      CONTENT: "总记录"
                    [TEXT: overview_total_value]
                      ATTR: Variant("h3")
                      CONTENT: "{{count|0}}"
                  [STACK: overview_focus]
                    { Gap: 1 }
                    [TEXT: overview_focus_label]
                      ATTR: Variant("caption"), Color("muted")
                      CONTENT: "当前视图"
                    [TEXT: overview_focus_value]
                      ATTR: Variant("body")
                      CONTENT: "{{active_view|全部数据}}"
                  [STACK: overview_owner]
                    { Gap: 1 }
                    [TEXT: overview_owner_label]
                      ATTR: Variant("caption"), Color("muted")
                      CONTENT: "数据说明"
                    [TEXT: overview_owner_value]
                      ATTR: Variant("body")
                      CONTENT: "{{summary_hint|支持批量处理与条件筛选}}"

  [SECTION: view_tabs]
    [CARD: view_selector_shell]
      [CARD_CONTENT: view_selector_content]
        [FLEX: view_selector_row]
          { Justify: "Between", Align: "Center", Wrap: true, Gap: 3 }
          [STACK: view_selector_meta]
            { Gap: 1 }
            [TEXT: view_selector_title]
              ATTR: Variant("body")
              CONTENT: "数据视图"
            [TEXT: view_selector_desc]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{view_desc|在同一套企业布局中切换不同工作视角}}"
          [TABS: view_selector]
            ATTR: DefaultValue("all")
            [TABS_LIST: view_tab_list]
              [TABS_TRIGGER: trigger_all]
                ATTR: Value("all")
                CONTENT: "全部"

  [SECTION: filter_section]
    [CARD: filter_card]
      ATTR: Variant("fit365-panel")
      [CARD_HEADER: filter_header]
        [CARD_TITLE: filter_title]
          CONTENT: "筛选与查询"
        [CARD_DESCRIPTION: filter_desc]
          CONTENT: "{{filter_desc|保留业务筛选条件，同时统一企业级工具栏层次}}"
      [CARD_CONTENT: filter_content]
        [STACK: filter_stack]
          { Gap: 3 }
          [FLEX: filter_row]
            { Gap: 4, Align: "End", Wrap: true }
            [STACK: filter_fields]
              BIND: Filters("read")
            [BUTTON: filter_submit]
              ATTR: Variant("secondary"), Click("filter_submit")
              CONTENT: "查询"
          [FLEX: filter_summary]
            { Justify: "Between", Align: "Center", Wrap: true, Gap: 2 }
            [TEXT: filter_summary_text]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{filter_summary|默认保留最近一次筛选条件与结果摘要}}"
            [BADGE: filter_summary_badge]
              ATTR: Variant("outline")
              CONTENT: "{{result_summary|共 0 条结果}}"

  [IF: NOT rows_empty]
    [SECTION: table_section]
      [CARD: table_card]
        ATTR: Variant("fit365-shell")
        [CARD_HEADER: table_header]
          [FLEX: table_header_row]
            { Justify: "Between", Align: "Center", Wrap: true, Gap: 3 }
            [STACK: table_header_meta]
              { Gap: 1 }
              [CARD_TITLE: table_title]
                CONTENT: "结果列表"
              [CARD_DESCRIPTION: table_desc]
                CONTENT: "{{table_desc|默认提供清晰的表头、数据区与分页承接}}"
            [BADGE: table_result_badge]
              ATTR: Variant("secondary")
              CONTENT: "{{count|0}} 条记录"
        [CARD_CONTENT: table_card_content]
          [TABLE: data_table]
            [TABLE_HEADER: data_header]
              [TABLE_ROW: header_row]
                [GRID: field_headers]
                  BIND: Fields("*")
            [TABLE_BODY: data_body]
              [GRID: field_values]
                BIND: Fields("*")
        [CARD_FOOTER: table_footer]
          [FLEX: table_footer_row]
            { Justify: "Between", Align: "Center", Wrap: true, Gap: 2 }
            [TEXT: table_footer_text]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{table_footer|支持标准列表浏览、导出前核对与跳转明细}}"
            [BADGE: table_footer_badge]
              ATTR: Variant("outline")
              CONTENT: "{{active_view|全部数据}}"
  [/IF]

  [IF: rows_empty]
    [SECTION: empty_section]
      [CARD: empty_shell]
        ATTR: Variant("fit365-panel")
        [CARD_HEADER: empty_header]
          [CARD_TITLE: empty_title]
            CONTENT: "暂无数据"
          [CARD_DESCRIPTION: empty_desc]
            CONTENT: "{{empty_hint|筛选条件已保留，可直接调整后再次查询}}"
        [CARD_CONTENT: empty_content]
          [EMPTY_STATE: no_data]
            ATTR: Description("暂无数据")
  [/IF]

  [SECTION: footer]
    [CARD: footer_shell]
      ATTR: Variant("fit365-panel")
      [CARD_CONTENT: footer_content]
        [FLEX: footer_row]
          { Justify: "Between", Align: "Center", Wrap: true, Gap: 3 }
          [STACK: footer_meta]
            { Gap: 1 }
            [TEXT: footer_title]
              ATTR: Variant("body")
              CONTENT: "结果翻页"
            [TEXT: footer_hint]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{footer_hint|分页与结果摘要保持同一层级，便于连续浏览}}"
          [FLEX: pagination_bar]
            BIND: Pagination()

  # ── 变体: SelectionMode("multi") ──────────────────────────
  [SECTION: header@multi]
    [CARD: multi_header_shell]
      [CARD_CONTENT: multi_header_content]
        [FLEX: header_bar]
          { Justify: "Between", Align: "Center", Wrap: true, Gap: 3 }
          [STACK: multi_header_meta]
            { Gap: 2 }
            [TEXT: page_title]
              ATTR: Variant("title")
              CONTENT: "{{page_title|批量操作}}"
            [TEXT: multi_header_hint]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{selection_summary|已选择 0 项，可继续批量处理}}"
          [FLEX: header_actions]
            { Gap: 2, Wrap: true }
            [BUTTON: select_all_btn]
              ATTR: Variant("secondary"), Click("select_all")
              CONTENT: "全选"
            [BUTTON: clear_selection_btn]
              ATTR: Variant("ghost"), Click("clear_selection")
              CONTENT: "清除选择"

  [SECTION: filter_section@multi]
    [CARD: action_card]
      [CARD_HEADER: action_header]
        [CARD_TITLE: action_title]
          CONTENT: "批量操作工具栏"
        [CARD_DESCRIPTION: action_desc]
          CONTENT: "{{bulk_hint|在同一工具栏中查看选择结果并执行批量动作}}"
      [CARD_CONTENT: action_content]
        [FLEX: action_row]
          { Justify: "Between", Align: "Center", Wrap: true, Gap: 3 }
          [TEXT: selection_count]
            CONTENT: "{{selection_summary|已选择 0 项}}"
          [FLEX: bulk_buttons]
            { Gap: 2, Wrap: true }
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
    [CARD: multi_table_shell]
      ATTR: Variant("fit365-shell")
      [CARD_HEADER: multi_table_header]
        [FLEX: multi_table_header_row]
          { Justify: "Between", Align: "Center", Wrap: true, Gap: 3 }
          [CARD_TITLE: multi_table_title]
            CONTENT: "批量操作列表"
          [BADGE: multi_table_badge]
            ATTR: Variant("secondary")
            CONTENT: "{{selection_summary|已选择 0 项}}"
      [CARD_CONTENT: multi_table_content]
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
    [CARD: search_header_shell]
      ATTR: Variant("fit365-shell")
      [CARD_CONTENT: search_header_content]
        [STACK: search_header]
          { Gap: 3 }
          [TEXT: page_title]
            ATTR: Variant("title")
            CONTENT: "{{page_title|搜索}}"
          [TEXT: search_header_hint]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "{{search_hint|在统一搜索栏中完成范围切换与结果筛选}}"
          [FLEX: search_bar]
            { Gap: 2, Align: "Center", Wrap: true }
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
    [CARD: search_summary_shell]
      ATTR: Variant("fit365-panel")
      [CARD_CONTENT: search_summary_content]
        [FLEX: result_summary]
          { Justify: "Between", Align: "Center", Wrap: true, Gap: 2 }
          [TEXT: result_count]
            ATTR: Variant("body"), Color("muted")
            CONTENT: "{{result_summary|共 0 条结果}}"
          [FLEX: sort_options]
            { Gap: 2, Wrap: true }
            [SELECT: sort_by]
              ATTR: Name("sort_by"), Label("排序")
              CONTENT: "相关度:relevance"
              CONTENT: "最新:newest"
              CONTENT: "最早:oldest"

  # ── 变体: Display("card_grid") ────────────────────────────
  [SECTION: header@card_grid]
    [CARD: card_grid_header_shell]
      ATTR: Variant("fit365-shell")
      [CARD_CONTENT: card_grid_header_content]
        [STACK: card_grid_header_stack]
          { Gap: 3 }
          [FLEX: shell_nav]
            { Justify: "Around", Wrap: true, Gap: 2 }
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
            { Gap: 2, PaddingX: 3, PaddingY: 2, Wrap: true, Align: "Center" }
            [INPUT: search_input]
              ATTR: Name("keyword"), Placeholder("搜索")

  [SECTION: table_section@card_grid]
    [CARD: result_grid_shell]
      ATTR: Variant("fit365-shell")
      [CARD_HEADER: result_grid_header]
        [CARD_TITLE: result_grid_title]
          CONTENT: "卡片结果"
        [CARD_DESCRIPTION: result_grid_desc]
          CONTENT: "{{grid_desc|以统一卡片层次展示数据摘要与跳转入口}}"
      [CARD_CONTENT: result_grid_content]
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
