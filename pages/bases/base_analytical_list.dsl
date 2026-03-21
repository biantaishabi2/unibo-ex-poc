[PAGE: base_analytical_list]
  ATTR: Title("分析列表")
  [SECTION: header]
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [STACK: page_meta]
        BIND: EntityMeta()
  [SECTION: kpi_tags]
    [FLEX: kpi_row]
      { Gap: 4 }
      [CARD: kpi_total]
        [CARD_CONTENT: kpi_total_content]
          [TEXT: kpi_total_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "总计"
          [TEXT: kpi_total_value]
            ATTR: Variant("h3")
            CONTENT: "{{total|0}}"
      [CARD: kpi_avg]
        [CARD_CONTENT: kpi_avg_content]
          [TEXT: kpi_avg_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "均值"
          [TEXT: kpi_avg_value]
            ATTR: Variant("h3")
            CONTENT: "{{average|0}}"
      [CARD: kpi_count]
        [CARD_CONTENT: kpi_count_content]
          [TEXT: kpi_count_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "条数"
          [TEXT: kpi_count_value]
            ATTR: Variant("h3")
            CONTENT: "{{count|0}}"
  [SECTION: chart_section]
    [CARD: chart_card]
      [CARD_CONTENT: chart_content]
        [CARD: chart_area]
          BIND: Chart(type: "column")
  [SECTION: table_section]
    [TABLE: data_table]
      [TABLE_HEADER: data_header]
        [TABLE_ROW: header_row]
          [GRID: field_headers]
            BIND: Fields("*")
      [TABLE_BODY: data_body]
        [GRID: field_values]
          BIND: Fields("*")
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
  [SECTION: footer]
    [FLEX: pagination_bar]
      BIND: Pagination()
