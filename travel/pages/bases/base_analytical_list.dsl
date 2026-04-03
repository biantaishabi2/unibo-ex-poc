[PAGE: base_analytical_list]
  ATTR: Title("分析列表"), FullHeight(true), Padding(0), Variant("fit365-canvas")
  [SECTION: header]
    [CARD: analytical_header_card]
      ATTR: Variant("fit365-shell"), ClassName("overflow-hidden")
      [CARD_CONTENT: analytical_header_content]
        [STACK: analytical_header_stack]
          ATTR: Gap(0)
          [FLEX: header_bar]
            ATTR: ClassName("bg-[linear-gradient(90deg,var(--color-primary-dark-2)_0%,var(--color-primary-dark-1)_55%,var(--color-primary)_100%)] px-6 py-4 text-white"), Justify("Between"), Align("Center"), Wrap(true), Gap(3)
            [STACK: header_info]
              ATTR: Gap(2)
              [STACK: page_meta]
                BIND: EntityMeta()
              [TEXT: analytical_header_hint]
                ATTR: Variant("caption")
                CONTENT: "{{analysis_hint|图表、指标与结果表默认形成统一分析工作区}}"
            [BADGE: analytical_refresh_badge]
              ATTR: Variant("outline")
              CONTENT: "{{refresh_status|数据已刷新}}"
          [FLEX: analytical_summary_row]
            ATTR: ClassName("px-6 py-5"), Gap(3), Wrap(true)
            [STACK: analytical_focus]
              { Gap: 1 }
              [TEXT: analytical_focus_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "分析主题"
              [TEXT: analytical_focus_value]
                ATTR: Variant("body")
                CONTENT: "{{analysis_topic|关键运营指标}}"
            [STACK: analytical_scope]
              { Gap: 1 }
              [TEXT: analytical_scope_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "统计口径"
              [TEXT: analytical_scope_value]
                ATTR: Variant("body")
                CONTENT: "{{analysis_scope|默认按当前筛选条件汇总}}"
            [STACK: analytical_updated]
              { Gap: 1 }
              [TEXT: analytical_updated_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "更新时间"
              [TEXT: analytical_updated_value]
                ATTR: Variant("body")
                CONTENT: "{{updated_at|刚刚}}"

  [SECTION: kpi_tags]
    [GRID: kpi_grid]
      { Columns: 3, Gap: 3 }
      [CARD: kpi_total]
        ATTR: Variant("fit365-soft")
        [CARD_CONTENT: kpi_total_content]
          [TEXT: kpi_total_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "总计"
          [TEXT: kpi_total_value]
            ATTR: Variant("h3")
            CONTENT: "{{total|0}}"
      [CARD: kpi_avg]
        ATTR: Variant("fit365-soft")
        [CARD_CONTENT: kpi_avg_content]
          [TEXT: kpi_avg_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "均值"
          [TEXT: kpi_avg_value]
            ATTR: Variant("h3")
            CONTENT: "{{average|0}}"
      [CARD: kpi_count]
        ATTR: Variant("fit365-soft")
        [CARD_CONTENT: kpi_count_content]
          [TEXT: kpi_count_label]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "条数"
          [TEXT: kpi_count_value]
            ATTR: Variant("h3")
            CONTENT: "{{count|0}}"

  [SECTION: chart_section]
    [CARD: chart_card]
      ATTR: Variant("fit365-shell")
      [CARD_HEADER: chart_header]
        [FLEX: chart_header_row]
          { Justify: "Between", Align: "Center", Wrap: true, Gap: 3 }
          [STACK: chart_header_meta]
            { Gap: 1 }
            [CARD_TITLE: chart_title]
              CONTENT: "趋势图表"
            [CARD_DESCRIPTION: chart_desc]
              CONTENT: "{{chart_desc|把关键趋势与当前筛选上下文放在同一层视觉框架内}}"
          [BADGE: chart_badge]
            ATTR: Variant("secondary")
            CONTENT: "{{chart_mode|柱状图}}"
      [CARD_CONTENT: chart_content]
        [STACK: chart_stack]
          { Gap: 3 }
          [TEXT: chart_summary]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "{{chart_summary|图表区默认承接趋势分析与指标对比}}"
          [CARD: chart_area]
            ATTR: Variant("fit365-soft")
            BIND: Chart(type: "column")

  [SECTION: table_section]
    [CARD: analytical_table_card]
      ATTR: Variant("fit365-shell")
      [CARD_HEADER: analytical_table_header]
        [FLEX: analytical_table_header_row]
          { Justify: "Between", Align: "Center", Wrap: true, Gap: 3 }
          [STACK: analytical_table_meta]
            { Gap: 1 }
            [CARD_TITLE: analytical_table_title]
              CONTENT: "明细结果"
            [CARD_DESCRIPTION: analytical_table_desc]
              CONTENT: "{{table_desc|图表之下保留明细核对区，方便继续钻取与校验}}"
          [BADGE: analytical_table_badge]
            ATTR: Variant("outline")
            CONTENT: "{{count|0}} 条明细"
      [CARD_CONTENT: analytical_table_content]
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
      ATTR: Variant("fit365-panel")
      [CARD_HEADER: filter_header]
        [CARD_TITLE: filter_title]
          CONTENT: "分析条件"
        [CARD_DESCRIPTION: filter_desc]
          CONTENT: "{{filter_desc|统一承接筛选项与统计范围说明，避免分析区裸露堆叠}}"
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
          [TEXT: filter_summary]
            ATTR: Variant("caption"), Color("muted")
            CONTENT: "{{filter_summary|筛选条件与图表/表格共用同一分析语义}}"

  [SECTION: footer]
    [CARD: analytical_footer_card]
      ATTR: Variant("fit365-panel")
      [CARD_CONTENT: analytical_footer_content]
        [FLEX: footer_row]
          { Justify: "Between", Align: "Center", Wrap: true, Gap: 3 }
          [STACK: footer_meta]
            { Gap: 1 }
            [TEXT: footer_title]
              ATTR: Variant("body")
              CONTENT: "结果翻页"
            [TEXT: footer_hint]
              ATTR: Variant("caption"), Color("muted")
              CONTENT: "{{footer_hint|继续翻页时保留当前分析语境与摘要信息}}"
          [FLEX: pagination_bar]
            BIND: Pagination()
