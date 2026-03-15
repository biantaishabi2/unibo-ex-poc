[PAGE: flight_offer_tree]
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
          [INPUT: filter_departure_at]
            ATTR: Name("departure_at_from"), Label("起飞时间 起")
          [SELECT: filter_sale_status]
            ATTR: Name("sale_status"), Label("销售状态")
          [BUTTON: filter_submit]
            ATTR: Variant("secondary"), Click("filter_submit")
            CONTENT: "查询"

  [SECTION: table_section]
    [SPLIT: main_split]
      ATTR: Ratio("1:3")
      [STACK: left_panel]
        [TREE: airline_tree]
          CONTENT: "按航空公司分组"
      [STACK: right_panel]
    [TABLE: data_table]
      [TABLE_HEADER: data_header]
        [TABLE_ROW: header_row]
          [TABLE_HEAD: th_placeholder]
            CONTENT: "数据列"
      [TABLE_BODY: data_body]
        [TEXT: body_placeholder]
          CONTENT: "数据行"
  [SECTION: footer]
    [TEXT: pagination]
      CONTENT: "分页"
