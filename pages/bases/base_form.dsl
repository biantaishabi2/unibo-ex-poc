[PAGE: base_form]
  ATTR: Title("表单")

  [SECTION: breadcrumb_section]
    [FLEX: breadcrumb_bar]

  [SECTION: header]
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [STACK: page_meta]
        BIND: EntityMeta()
      [FLEX: header_actions]
        { Gap: 2 }
        [BUTTON: cancel_btn]
          ATTR: Variant("ghost"), Click("form_cancel")
          CONTENT: "取消"
        [BUTTON: save_draft_btn]
          ATTR: Variant("secondary"), Click("save_draft")
          CONTENT: "保存草稿"
        [BUTTON: submit_btn]
          ATTR: Variant("primary"), Click("form_submit")
          CONTENT: "提交"

  [SECTION: form_section]
    [FORM: main_form]
      ATTR: Submit("form_submit"), Change("form_change")
      [CARD: basic_info_card]
        [CARD_HEADER: basic_info_header]
          [CARD_TITLE: basic_info_title]
            CONTENT: "{{section_1_title|基本信息}}"
        [CARD_CONTENT: basic_info_content]
          [GRID: basic_info_grid]
            BIND: Form("create")
            { Columns: 2, Gap: 4 }

  [SECTION: form_footer]
    [FLEX: footer_actions]
      { Justify: "End", Gap: 2 }
      [BUTTON: footer_cancel]
        ATTR: Variant("secondary"), Click("form_cancel")
        CONTENT: "取消"
      [BUTTON: footer_submit]
        BIND: Action("create")
        ATTR: Variant("primary"), Click("form_submit")
        CONTENT: "提交"

  # ── import_export 变体 ──────────────────────────────────────

  [SECTION: header@import_export]
    [FLEX: header_bar]
      { Justify: "Between", Align: "Center" }
      [TEXT: page_title]
        ATTR: Variant("title")
        CONTENT: "{{page_title|数据导入导出}}"
      [FLEX: header_actions]
        { Gap: 2 }
        [BUTTON: download_template_btn]
          ATTR: Variant("secondary"), Click("download_template")
          CONTENT: "下载模板"

  [SECTION: form_section@import_export]
    [FLEX: step_bar]
      { Justify: "Center", Align: "Center", Gap: 4 }
      [STACK: step_1]
        { Align: "Center" }
        [BADGE: step_1_indicator]
          CONTENT: "1"
        [TEXT: step_1_label]
          ATTR: Variant("caption")
          CONTENT: "{{step_1_label|选择模式}}"
      [TEXT: step_sep_1]
        ATTR: Variant("muted")
        CONTENT: "—"
      [STACK: step_2]
        { Align: "Center" }
        [BADGE: step_2_indicator]
          CONTENT: "2"
        [TEXT: step_2_label]
          ATTR: Variant("caption")
          CONTENT: "{{step_2_label|上传/配置}}"
      [TEXT: step_sep_2]
        ATTR: Variant("muted")
        CONTENT: "—"
      [STACK: step_3]
        { Align: "Center" }
        [BADGE: step_3_indicator]
          CONTENT: "3"
        [TEXT: step_3_label]
          ATTR: Variant("caption")
          CONTENT: "{{step_3_label|执行结果}}"

    [TABS: mode_tabs]
      ATTR: DefaultValue("import")
      [TABS_LIST: mode_tab_list]
        [TABS_TRIGGER: trigger_import]
          ATTR: Value("import")
          CONTENT: "导入"
        [TABS_TRIGGER: trigger_export]
          ATTR: Value("export")
          CONTENT: "导出"

      [TABS_CONTENT: content_import]
        ATTR: Value("import")
        [CARD: upload_card]
          [CARD_HEADER: upload_header]
            [CARD_TITLE: upload_title]
              CONTENT: "上传文件"
          [CARD_CONTENT: upload_content]
            [STACK: upload_area]
              { Gap: 4 }
              [TEXT: upload_hint]
                ATTR: Variant("body"), Color("muted")
                CONTENT: "支持 .xlsx、.csv 格式，单次最大 10MB"
              [INPUT: file_upload]
                ATTR: Name("file"), Type("file"), Label("选择文件")
              [CARD: import_options_card]
                [CARD_HEADER: options_header]
                  [CARD_TITLE: options_title]
                    CONTENT: "导入选项"
                [CARD_CONTENT: options_content]
                  [STACK: options_stack]
                    { Gap: 3 }
                    [SELECT: duplicate_strategy]
                      ATTR: Name("duplicate_strategy"), Label("重复数据处理")
                      CONTENT: "跳过:skip"
                      CONTENT: "覆盖:overwrite"
                      CONTENT: "追加:append"
                    [SELECT: error_strategy]
                      ATTR: Name("error_strategy"), Label("错误处理")
                      CONTENT: "中断导入:abort"
                      CONTENT: "跳过错误行:skip_error"
              [FLEX: import_actions]
                { Justify: "End", Gap: 2 }
                [BUTTON: preview_btn]
                  ATTR: Variant("secondary"), Click("import_preview")
                  CONTENT: "预览"
                [BUTTON: import_btn]
                  ATTR: Variant("primary"), Click("import_execute")
                  CONTENT: "开始导入"

      [TABS_CONTENT: content_export]
        ATTR: Value("export")
        [CARD: export_card]
          [CARD_HEADER: export_header]
            [CARD_TITLE: export_title]
              CONTENT: "导出设置"
          [CARD_CONTENT: export_content]
            [STACK: export_stack]
              { Gap: 4 }
              [SELECT: export_format]
                ATTR: Name("export_format"), Label("导出格式")
                CONTENT: "Excel (.xlsx):xlsx"
                CONTENT: "CSV (.csv):csv"
              [SELECT: export_scope]
                ATTR: Name("export_scope"), Label("导出范围")
                CONTENT: "当前筛选结果:filtered"
                CONTENT: "全部数据:all"
                CONTENT: "选中项:selected"
              [FLEX: export_actions]
                { Justify: "End", Gap: 2 }
                [BUTTON: export_btn]
                  ATTR: Variant("primary"), Click("export_execute")
                  CONTENT: "开始导出"

    [CARD: result_card]
      [CARD_HEADER: result_header]
        [CARD_TITLE: result_title]
          CONTENT: "操作结果"
      [CARD_CONTENT: result_content]
        [STACK: result_stats]
          { Gap: 3 }
          [FLEX: stat_row]
            { Gap: 6 }
            [STACK: stat_total]
              [TEXT: label_total]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "总记录数"
              [TEXT: value_total]
                ATTR: Variant("h2"), Weight("bold")
                CONTENT: "{{result_total|0}}"
            [STACK: stat_success]
              [TEXT: label_success]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "成功"
              [TEXT: value_success]
                ATTR: Variant("h2"), Weight("bold")
                CONTENT: "{{result_success|0}}"
            [STACK: stat_failed]
              [TEXT: label_failed]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "失败"
              [TEXT: value_failed]
                ATTR: Variant("h2"), Weight("bold"), Color("destructive")
                CONTENT: "{{result_failed|0}}"

  [SECTION: form_footer@import_export]
    [FLEX: nav_buttons]
      { Justify: "Between" }
      [BUTTON: prev_btn]
        ATTR: Variant("secondary"), Click("wizard_prev")
        CONTENT: "上一步"
      [FLEX: right_buttons]
        { Gap: 2 }
        [BUTTON: cancel_btn]
          ATTR: Variant("ghost"), Click("navigate_back")
          CONTENT: "取消"
        [BUTTON: next_btn]
          ATTR: Variant("primary"), Click("wizard_next")
          CONTENT: "下一步"
  [SECTION: header@wizard]
    [FLEX: wz_header_bar]
      { Justify: "Between", Align: "Center" }
      [STACK: wz_page_meta]
        BIND: EntityMeta()
      [FLEX: wz_header_actions]
        { Gap: 2 }
        [BUTTON: wz_hdr_cancel_btn]
          ATTR: Variant("ghost"), Click("wizard_cancel")
          CONTENT: "取消"
        [BUTTON: wz_hdr_submit_btn]
          ATTR: Variant("primary"), Click("wizard_submit")
          CONTENT: "提交"

  [SECTION: form_section@wizard]
    [FLEX: wz_step_bar]
      { Justify: "Center", Align: "Center", Gap: 4 }
      [STACK: wz_step_1]
        { Align: "Center" }
        [BADGE: wz_step_1_indicator]
          CONTENT: "1"
        [TEXT: wz_step_1_label]
          ATTR: Variant("caption")
          CONTENT: "{{step_1_label|基本信息}}"
      [TEXT: wz_step_sep_1]
        ATTR: Variant("muted")
        CONTENT: "—"
      [STACK: wz_step_2]
        { Align: "Center" }
        [BADGE: wz_step_2_indicator]
          CONTENT: "2"
        [TEXT: wz_step_2_label]
          ATTR: Variant("caption")
          CONTENT: "{{step_2_label|详细配置}}"
      [TEXT: wz_step_sep_2]
        ATTR: Variant("muted")
        CONTENT: "—"
      [STACK: wz_step_3]
        { Align: "Center" }
        [BADGE: wz_step_3_indicator]
          CONTENT: "3"
        [TEXT: wz_step_3_label]
          ATTR: Variant("caption")
          CONTENT: "{{step_3_label|确认提交}}"
    [CARD: wz_step_1_card]
      [CARD_HEADER: wz_step_1_header]
        [CARD_TITLE: wz_step_1_title]
          CONTENT: "{{step_1_label|基本信息}}"
      [CARD_CONTENT: wz_step_1_content]
        [GRID: wz_step_1_grid]
          BIND: Form("create")
          { Columns: 2, Gap: 4 }
    [CARD: wz_step_2_card]
      [CARD_HEADER: wz_step_2_header]
        [CARD_TITLE: wz_step_2_title]
          CONTENT: "{{step_2_label|详细配置}}"
      [CARD_CONTENT: wz_step_2_content]
        [GRID: wz_step_2_grid]
          { Columns: 2, Gap: 4 }
    [CARD: wz_step_3_card]
      [CARD_HEADER: wz_step_3_header]
        [CARD_TITLE: wz_step_3_title]
          CONTENT: "{{step_3_label|确认提交}}"
      [CARD_CONTENT: wz_step_3_content]
        [STACK: wz_summary_display]
          { Gap: 3 }
          [TEXT: wz_summary_fields]
            CONTENT: "汇总确认区域"

  [SECTION: form_footer@wizard]
    [FLEX: wz_nav_buttons]
      { Justify: "Between" }
      [BUTTON: wz_prev_btn]
        ATTR: Variant("secondary"), Click("wizard_prev")
        CONTENT: "上一步"
      [FLEX: wz_right_buttons]
        { Gap: 2 }
        [BUTTON: wz_cancel_btn]
          ATTR: Variant("ghost"), Click("wizard_cancel")
          CONTENT: "取消"
        [BUTTON: wz_next_btn]
          ATTR: Variant("primary"), Click("wizard_next")
          CONTENT: "下一步"
        [BUTTON: wz_submit_btn]
          ATTR: Variant("primary"), Click("wizard_submit")
          CONTENT: "提交"
