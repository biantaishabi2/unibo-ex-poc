[PAGE: base_list]
  ATTR: Title("列表")
  [SECTION: header]
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [TEXT: page_title]
        ATTR: Variant("title")
        CONTENT: "{{page_title|数据列表}}"
      [BUTTON: create_btn]
        ATTR: Variant("primary"), Click("navigate_create")
        CONTENT: "新建"
  [SECTION: filter_section]
    [CARD: filter_card]
      [CARD_CONTENT: filter_content]
        [FLEX: filter_row]
          { Gap: 4, Align: "Center" }
          [TEXT: filter_placeholder]
            CONTENT: "筛选区域"
          [BUTTON: filter_submit]
            ATTR: Variant("secondary"), Click("filter_submit")
            CONTENT: "查询"
  [SECTION: table_section]
    [TABLE: data_table]
      [TABLE_HEADER: data_header]
        [TABLE_ROW: header_row]
          [TABLE_HEAD: th_placeholder]
            CONTENT: "数据列"
      [TABLE_BODY: data_body]
        [TEXT: body_placeholder]
          CONTENT: "数据行"
  [SECTION: empty_section]
    [IF: rows_empty]
      [EMPTY_STATE: no_data]
        ATTR: Description("暂无数据")
    [/IF]
  [SECTION: footer]
    [TEXT: pagination]
      CONTENT: "分页"
