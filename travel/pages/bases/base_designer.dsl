[PAGE: base_designer]
  ATTR: Title("设计器"), FullHeight(true), Padding(0), Variant("fit365-canvas")

  [CONTAINER: designer_shell]
    ATTR: Size("XLarge"), Variant("fit365-page-shell-compact")

    [SECTION: header]
      ATTR: Layout("none")
      [CARD: header_surface]
        ATTR: Variant("fit365-hero"), ClassName("overflow-hidden")
        [CARD_CONTENT: header_surface_content]
          ATTR: ClassName("space-y-5 px-8 py-7")
          [FLEX: header_bar]
            ATTR: Justify("Between"), Align("Center"), ClassName("gap-4")
            [FLEX: title_group]
              ATTR: Gap(3), Align("Center"), Wrap(true)
              [TEXT: page_title]
                ATTR: Variant("Title"), ClassName("text-3xl font-semibold tracking-tight text-white")
                CONTENT: "{{designer_title|企业可视化设计器}}"
              [BADGE: save_status]
                ATTR: Variant("Secondary"), ClassName("border-white/20 bg-white/15 text-white")
                CONTENT: "{{save_status|已保存}}"
            [FLEX: header_actions]
              ATTR: Gap(2), Wrap(true)
              [BUTTON: undo_btn]
                ATTR: Variant("Ghost"), Click("designer_undo"), ClassName("border border-white/15 bg-white/10 text-white hover:bg-white/15")
                CONTENT: "撤销"
              [BUTTON: redo_btn]
                ATTR: Variant("Ghost"), Click("designer_redo"), ClassName("border border-white/15 bg-white/10 text-white hover:bg-white/15")
                CONTENT: "重做"
              [BUTTON: preview_btn]
                ATTR: Variant("Outline"), Click("designer_preview"), ClassName("border-white/20 bg-white/10 text-white hover:bg-white/15")
                CONTENT: "预览"
              [BUTTON: save_btn]
                ATTR: Variant("Secondary"), Click("designer_save"), ClassName("bg-white text-[var(--color-primary-dark-2)] hover:bg-[var(--color-primary-light-2)]")
                CONTENT: "保存"
              [BUTTON: publish_btn]
                ATTR: Variant("Primary"), Click("designer_publish"), ClassName("bg-[var(--color-primary-light-1)] text-[var(--color-primary-dark-2)] hover:bg-[var(--color-primary-light-2)]")
                CONTENT: "发布"
          [COLUMNS: header_metrics]
            { Gap: "4" }
            ATTR: Layout("2:1:1")
            [CARD: header_brief]
              ATTR: ClassName("rounded-[22px] border border-white/15 bg-white/14 shadow-none backdrop-blur")
              [CARD_CONTENT: header_brief_content]
                ATTR: ClassName("space-y-2 px-5 py-5")
                [TEXT: header_brief_title]
                  ATTR: Variant("Body"), ClassName("font-semibold text-white")
                  CONTENT: "设计说明"
                [TEXT: header_brief_text]
                  ATTR: Variant("Caption"), ClassName("text-white/80")
                  CONTENT: "默认模板补足企业设计器的壳层、状态与协作信息，让三栏布局不再像裸容器。"
            [CARD: header_metric_1]
              ATTR: ClassName("rounded-[22px] border border-white/15 bg-white/14 shadow-none backdrop-blur")
              [CARD_CONTENT: header_metric_1_content]
                ATTR: ClassName("space-y-1 px-5 py-5")
                [TEXT: header_metric_1_label]
                  ATTR: Variant("Caption"), ClassName("text-white/70")
                  CONTENT: "最近修改"
                [TEXT: header_metric_1_value]
                  ATTR: Variant("Title"), ClassName("text-2xl text-white")
                  CONTENT: "{{recent_edit|12 分钟前}}"
            [CARD: header_metric_2]
              ATTR: ClassName("rounded-[22px] border border-white/15 bg-white/14 shadow-none backdrop-blur")
              [CARD_CONTENT: header_metric_2_content]
                ATTR: ClassName("space-y-1 px-5 py-5")
                [TEXT: header_metric_2_label]
                  ATTR: Variant("Caption"), ClassName("text-white/70")
                  CONTENT: "协作者"
                [TEXT: header_metric_2_value]
                  ATTR: Variant("Title"), ClassName("text-2xl text-white")
                  CONTENT: "{{collaborator_count|04}}"

    [SECTION: workspace]
      ATTR: Layout("none")
      [COLUMNS: main_split]
        { Gap: "4" }
        ATTR: Layout("1:3:1")

        [CARD: toolbox_panel]
          ATTR: Variant("fit365-shell")
          [CARD_HEADER: toolbox_header]
            ATTR: ClassName("px-6 pt-6")
            [CARD_TITLE: toolbox_title]
              CONTENT: "组件库"
            [CARD_DESCRIPTION: toolbox_desc]
              CONTENT: "工具箱带有分组、搜索与拖入入口"
          [CARD_CONTENT: toolbox_content]
            ATTR: ClassName("space-y-4 px-6 pb-6")
            [INPUT: component_search]
              ATTR: Name("component_search"), Placeholder("搜索组件..."), ClassName("rounded-xl bg-[var(--color-bg-base)]")
            [STACK: component_list]
              ATTR: Gap(3)
              [TEXT: group_basic]
                ATTR: Variant("Caption"), ClassName("text-xs font-semibold uppercase tracking-[0.18em] text-[var(--color-text-tertiary)]")
                CONTENT: "基础组件"
              [BUTTON: comp_text]
                ATTR: Variant("Ghost"), Click("add_component_text"), ClassName("justify-start rounded-2xl border border-[var(--color-border-base)] bg-[var(--color-bg-base)] px-4 py-5")
                CONTENT: "文本"
              [BUTTON: comp_image]
                ATTR: Variant("Ghost"), Click("add_component_image"), ClassName("justify-start rounded-2xl border border-[var(--color-border-base)] bg-[var(--color-bg-base)] px-4 py-5")
                CONTENT: "图片"
              [BUTTON: comp_button]
                ATTR: Variant("Ghost"), Click("add_component_button"), ClassName("justify-start rounded-2xl border border-[var(--color-border-base)] bg-[var(--color-bg-base)] px-4 py-5")
                CONTENT: "按钮"
              [TEXT: group_layout]
                ATTR: Variant("Caption"), ClassName("pt-2 text-xs font-semibold uppercase tracking-[0.18em] text-[var(--color-text-tertiary)]")
                CONTENT: "布局组件"
              [BUTTON: comp_grid]
                ATTR: Variant("Ghost"), Click("add_component_grid"), ClassName("justify-start rounded-2xl border border-[var(--color-border-base)] bg-[var(--color-bg-base)] px-4 py-5")
                CONTENT: "栅格"
              [BUTTON: comp_card]
                ATTR: Variant("Ghost"), Click("add_component_card"), ClassName("justify-start rounded-2xl border border-[var(--color-border-base)] bg-[var(--color-bg-base)] px-4 py-5")
                CONTENT: "卡片"
              [TEXT: group_form]
                ATTR: Variant("Caption"), ClassName("pt-2 text-xs font-semibold uppercase tracking-[0.18em] text-[var(--color-text-tertiary)]")
                CONTENT: "表单组件"
              [BUTTON: comp_input]
                ATTR: Variant("Ghost"), Click("add_component_input"), ClassName("justify-start rounded-2xl border border-[var(--color-border-base)] bg-[var(--color-bg-base)] px-4 py-5")
                CONTENT: "输入框"
              [BUTTON: comp_select]
                ATTR: Variant("Ghost"), Click("add_component_select"), ClassName("justify-start rounded-2xl border border-[var(--color-border-base)] bg-[var(--color-bg-base)] px-4 py-5")
                CONTENT: "下拉选择"

        [CARD: canvas_panel]
          ATTR: Variant("fit365-shell")
          [CARD_HEADER: canvas_header]
            ATTR: ClassName("px-6 pt-6")
            [FLEX: canvas_toolbar]
              ATTR: Justify("Between"), Align("Center"), ClassName("gap-4")
              [STACK: canvas_toolbar_copy]
                ATTR: Gap(1)
                [TEXT: canvas_label]
                  ATTR: Variant("Body"), ClassName("text-base font-semibold")
                  CONTENT: "画布"
                [TEXT: canvas_subtitle]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                  CONTENT: "默认包含设备框、栅格背景与编辑状态"
              [FLEX: zoom_controls]
                ATTR: Gap(2), Align("Center")
                [BUTTON: zoom_out_btn]
                  ATTR: Variant("Ghost"), Size("sm"), Click("zoom_out"), ClassName("rounded-xl border border-[var(--color-border-base)] bg-[var(--color-bg-base)]")
                  CONTENT: "-"
                [TEXT: zoom_level]
                  ATTR: Variant("Caption"), ClassName("min-w-[56px] text-center text-[var(--color-text-tertiary)]")
                  CONTENT: "{{zoom_level|100%}}"
                [BUTTON: zoom_in_btn]
                  ATTR: Variant("Ghost"), Size("sm"), Click("zoom_in"), ClassName("rounded-xl border border-[var(--color-border-base)] bg-[var(--color-bg-base)]")
                  CONTENT: "+"
          [CARD_CONTENT: canvas_content]
            ATTR: ClassName("space-y-5 px-6 pb-6")
            [DIV: canvas_area]
              ATTR: ClassName("rounded-[28px] border border-dashed border-[var(--color-primary-light-1)] bg-[radial-gradient(circle_at_top,_rgba(var(--color-primary-rgb),0.18),_transparent_45%),linear-gradient(180deg,var(--color-primary-light-2)_0%,var(--color-bg-base)_100%)] px-6 py-6")
              [STACK: canvas_area_stack]
                ATTR: Gap(5), Align("Center")
                [CARD: canvas_preview_card]
                  ATTR: ClassName("w-full max-w-[520px] rounded-[26px] border-[var(--color-border-base)] bg-[var(--color-bg-card)] shadow-[var(--shadow-medium)]")
                  [CARD_HEADER: canvas_preview_header]
                    ATTR: ClassName("px-6 pt-6")
                    [FLEX: canvas_preview_meta]
                      ATTR: Justify("Between"), Align("Center")
                      [TEXT: canvas_preview_title]
                        ATTR: Variant("Body"), ClassName("font-semibold")
                        CONTENT: "{{canvas_title|首页布局预览}}"
                      [BADGE: canvas_preview_badge]
                        ATTR: Variant("Secondary")
                        CONTENT: "{{canvas_device|Desktop 1440}}"
                  [CARD_CONTENT: canvas_preview_content]
                    ATTR: ClassName("space-y-4 px-6 pb-6")
                    [DIV: canvas_preview_hero]
                      ATTR: ClassName("rounded-[20px] bg-[linear-gradient(135deg,var(--color-primary-dark-2)_0%,var(--color-primary-dark-1)_55%,var(--color-primary)_100%)] px-5 py-5 text-white")
                      [TEXT: canvas_preview_hero_title]
                        ATTR: Variant("Title"), ClassName("text-2xl text-white")
                        CONTENT: "站点主视觉"
                      [TEXT: canvas_preview_hero_desc]
                        ATTR: Variant("Caption"), ClassName("text-white/70")
                        CONTENT: "画布内预留真实布局结构，而不只是单行占位文案。"
                    [GRID: canvas_preview_grid]
                      { Columns: 2, Gap: 3 }
                      [CARD: canvas_preview_stat_1]
                        ATTR: ClassName("rounded-[20px] bg-[var(--color-primary-light-2)] shadow-none")
                        [CARD_CONTENT: canvas_preview_stat_1_content]
                          ATTR: ClassName("space-y-1 px-4 py-4")
                          [TEXT: canvas_preview_stat_1_label]
                            ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                            CONTENT: "模块"
                          [TEXT: canvas_preview_stat_1_value]
                            ATTR: Variant("Title"), ClassName("text-2xl")
                            CONTENT: "12"
                      [CARD: canvas_preview_stat_2]
                        ATTR: ClassName("rounded-[20px] bg-[var(--color-primary-light-2)] shadow-none")
                        [CARD_CONTENT: canvas_preview_stat_2_content]
                          ATTR: ClassName("space-y-1 px-4 py-4")
                          [TEXT: canvas_preview_stat_2_label]
                            ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                            CONTENT: "变量"
                          [TEXT: canvas_preview_stat_2_value]
                            ATTR: Variant("Title"), ClassName("text-2xl")
                            CONTENT: "48"
                [TEXT: canvas_placeholder]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                  CONTENT: "设计画布区域 - 可直接替换为真实拖放层或低代码编辑运行时。"
            [CARD: canvas_footer_brief]
              ATTR: Variant("fit365-soft")
              [CARD_CONTENT: canvas_footer_brief_content]
                ATTR: ClassName("px-5 py-5")
                [TEXT: canvas_footer_brief_text]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-secondary)]")
                  CONTENT: "中栏默认强化主画布存在感，避免设计器页面只剩三块普通卡片。"

        [CARD: properties_panel]
          ATTR: Variant("fit365-shell")
          [CARD_HEADER: properties_header]
            ATTR: ClassName("px-6 pt-6")
            [CARD_TITLE: properties_title]
              CONTENT: "属性配置"
            [CARD_DESCRIPTION: properties_desc]
              CONTENT: "右侧面板汇总组件状态、样式与事件"
          [CARD_CONTENT: properties_content]
            ATTR: ClassName("space-y-4 px-6 pb-6")
            [CARD: properties_summary]
              ATTR: Variant("fit365-muted")
              [CARD_CONTENT: properties_summary_content]
                ATTR: ClassName("space-y-2 px-4 py-4")
                [TEXT: properties_summary_label]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                  CONTENT: "当前选中"
                [TEXT: properties_summary_value]
                  ATTR: Variant("Body"), ClassName("font-semibold")
                  CONTENT: "{{current_component|Hero Banner}}"
                [TEXT: properties_summary_hint]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                  CONTENT: "已接入尺寸、视觉与交互属性面板。"
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
                [STACK: props_stack]
                  ATTR: Gap(3)
                  [TEXT: props_placeholder]
                    ATTR: Variant("Caption"), ClassName("text-[var(--color-text-secondary)]")
                    CONTENT: "选择组件后显示属性配置"
                  [CARD: props_preview_card]
                    ATTR: ClassName("rounded-[20px] border-[var(--color-border-base)] bg-[var(--color-bg-base)] shadow-none")
                    [CARD_CONTENT: props_preview_content]
                      ATTR: ClassName("space-y-2 px-4 py-4")
                      [TEXT: props_preview_label]
                        ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                        CONTENT: "默认字段"
                      [TEXT: props_preview_value]
                        ATTR: Variant("Caption"), ClassName("text-[var(--color-text-primary)]")
                        CONTENT: "标题、描述、按钮组、背景样式"
              [TABS_CONTENT: content_style]
                ATTR: Value("style")
                [TEXT: style_placeholder]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-secondary)]")
                  CONTENT: "选择组件后显示样式配置"
              [TABS_CONTENT: content_events]
                ATTR: Value("events")
                [TEXT: events_placeholder]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-secondary)]")
                  CONTENT: "选择组件后显示事件配置"
