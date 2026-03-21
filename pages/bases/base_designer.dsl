[PAGE: base_designer]
  ATTR: Title("设计器")

  [SECTION: breadcrumb_section]
    [FLEX: breadcrumb_bar]

  [SECTION: header]
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [FLEX: title_group]
        { Gap: 3, Align: "Center" }
        [STACK: page_meta]
          BIND: EntityMeta()
        [BADGE: save_status]
          CONTENT: "{{save_status|已保存}}"
      [FLEX: header_actions]
        { Gap: 2 }
        [BUTTON: undo_btn]
          ATTR: Variant("ghost"), Click("designer_undo")
          CONTENT: "撤销"
        [BUTTON: redo_btn]
          ATTR: Variant("ghost"), Click("designer_redo")
          CONTENT: "重做"
        [BUTTON: preview_btn]
          ATTR: Variant("secondary"), Click("designer_preview")
          CONTENT: "预览"
        [BUTTON: save_btn]
          ATTR: Variant("primary"), Click("designer_save")
          CONTENT: "保存"
        [BUTTON: publish_btn]
          ATTR: Variant("primary"), Click("designer_publish")
          CONTENT: "发布"

  [SECTION: workspace]
    [SPLIT: main_split]
      ATTR: Ratio("1:3:1")

      [CARD: toolbox_panel]
        [CARD_HEADER: toolbox_header]
          [CARD_TITLE: toolbox_title]
            CONTENT: "组件库"
        [CARD_CONTENT: toolbox_content]
          [INPUT: component_search]
            ATTR: Name("component_search"), Placeholder("搜索组件...")
          [STACK: component_list]
            { Gap: 2 }
            [TEXT: group_basic]
              ATTR: Variant("caption"), Weight("bold")
              CONTENT: "基础组件"
            [BUTTON: comp_text]
              ATTR: Variant("ghost"), Click("add_component_text")
              CONTENT: "文本"
            [BUTTON: comp_image]
              ATTR: Variant("ghost"), Click("add_component_image")
              CONTENT: "图片"
            [BUTTON: comp_button]
              ATTR: Variant("ghost"), Click("add_component_button")
              CONTENT: "按钮"
            [TEXT: group_layout]
              ATTR: Variant("caption"), Weight("bold")
              CONTENT: "布局组件"
            [BUTTON: comp_grid]
              ATTR: Variant("ghost"), Click("add_component_grid")
              CONTENT: "栅格"
            [BUTTON: comp_card]
              ATTR: Variant("ghost"), Click("add_component_card")
              CONTENT: "卡片"
            [TEXT: group_form]
              ATTR: Variant("caption"), Weight("bold")
              CONTENT: "表单组件"
            [BUTTON: comp_input]
              ATTR: Variant("ghost"), Click("add_component_input")
              CONTENT: "输入框"
            [BUTTON: comp_select]
              ATTR: Variant("ghost"), Click("add_component_select")
              CONTENT: "下拉选择"

      [CARD: canvas_panel]
        [CARD_HEADER: canvas_header]
          [FLEX: canvas_toolbar]
            { Justify: "Between", Align: "Center" }
            [TEXT: canvas_label]
              ATTR: Variant("body")
              CONTENT: "画布"
            [FLEX: zoom_controls]
              { Gap: 1 }
              [BUTTON: zoom_out_btn]
                ATTR: Variant("ghost"), Size("sm"), Click("zoom_out")
                CONTENT: "-"
              [TEXT: zoom_level]
                ATTR: Variant("caption")
                CONTENT: "{{zoom_level|100%}}"
              [BUTTON: zoom_in_btn]
                ATTR: Variant("ghost"), Size("sm"), Click("zoom_in")
                CONTENT: "+"
        [CARD_CONTENT: canvas_content]
          [STACK: canvas_area]
            { Gap: 2, Align: "Center" }
            [TEXT: canvas_placeholder]
              CONTENT: "设计画布区域 — 拖放组件到此处"

      [CARD: properties_panel]
        [CARD_HEADER: properties_header]
          [CARD_TITLE: properties_title]
            CONTENT: "属性配置"
        [CARD_CONTENT: properties_content]
          [TABS: property_tabs]
            ATTR: DefaultValue("props")
            [TABS_LIST: property_tab_list]
              [TABS_TRIGGER: trigger_props]
                ATTR: Value("props")
                CONTENT: "属性"
              [TABS_TRIGGER: trigger_style]
                ATTR: Value("style")
                CONTENT: "样式"
              [TABS_TRIGGER: trigger_events]
                ATTR: Value("events")
                CONTENT: "事件"
            [TABS_CONTENT: content_props]
              ATTR: Value("props")
              [GRID: props_fields]
                BIND: Fields("*")
            [TABS_CONTENT: content_style]
              ATTR: Value("style")
              [TEXT: style_placeholder]
                CONTENT: "选择组件后显示样式配置"
            [TABS_CONTENT: content_events]
              ATTR: Value("events")
              [TEXT: events_placeholder]
                CONTENT: "选择组件后显示事件配置"
