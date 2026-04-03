[PAGE: base_form]
  ATTR: FullHeight(true), Padding(0), Variant("fit365-canvas-soft")

  [CONTAINER: form_page_shell]
    ATTR: Size("XLarge"), Variant("fit365-page-shell-compact")

    [SECTION: form_header_section]
      ATTR: Id("form_header_section"), Layout("none")
      [CARD: form_header_card]
        ATTR: Variant("fit365-shell"), ClassName("overflow-hidden")
        [CARD_CONTENT: form_header_content]
          ATTR: ClassName("p-0")

          [STACK: form_header_stack]
            ATTR: Gap(0)

            [FLEX: form_header_topbar]
              ATTR: ClassName("bg-[linear-gradient(90deg,var(--color-primary-dark-2)_0%,var(--color-primary-dark-1)_55%,var(--color-primary)_100%)] px-6 py-4 text-white"), Justify("Between"), Align("Center"), Wrap(true)
              [SECTION: breadcrumb_section]
                [BREADCRUMB: form_breadcrumb]
                  [BREADCRUMB_LIST: form_breadcrumb_list]
                    [BREADCRUMB_ITEM: form_breadcrumb_home_item]
                      [BREADCRUMB_LINK: form_breadcrumb_home]
                        ATTR: Href("#")
                        CONTENT: "流程中心"
                    [BREADCRUMB_SEPARATOR: form_breadcrumb_sep_1]
                    [BREADCRUMB_ITEM: form_breadcrumb_module_item]
                      [BREADCRUMB_LINK: form_breadcrumb_module]
                        ATTR: Href("#")
                        CONTENT: "差旅申请"
                    [BREADCRUMB_SEPARATOR: form_breadcrumb_sep_2]
                    [BREADCRUMB_ITEM: form_breadcrumb_current_item]
                      [BREADCRUMB_PAGE: form_breadcrumb_current]
                        CONTENT: "{{form.mode|新建申请}}"
              [FLEX: form_header_meta]
                ATTR: Gap(3), Align("Center"), Wrap(true)
                [BADGE: form_header_scene_badge]
                  ATTR: Variant("Secondary")
                  CONTENT: "流程表单"
                [TEXT: form_header_saved_at]
                  ATTR: Variant("Muted"), ClassName("text-white/70")
                  CONTENT: "草稿保存于 {{form.saved_at|2026-03-27 21:45}}"

            [GRID: form_header_body]
              ATTR: Columns(3), Gap(6), ClassName("px-6 py-6")

              [SECTION: header]
                [STACK: form_title_panel]
                  ATTR: ClassName("lg:col-span-2 space-y-4")
                  [TEXT: form_title_kicker]
                  ATTR: Variant("Muted"), ClassName("uppercase tracking-[0.28em] text-xs text-[var(--color-primary-dark-1)]")
                    CONTENT: "{{form.process|差旅流程}}"
                  [TEXT: form_page_title]
                    ATTR: Variant("Title"), ClassName("text-3xl font-semibold text-[var(--color-text-base)]")
                    CONTENT: "{{form.title|出差申请单}}"
                  [TEXT: form_page_summary]
                    ATTR: Variant("Muted"), ClassName("max-w-3xl text-sm leading-6 text-[var(--color-text-secondary)]")
                    CONTENT: "{{form.summary|默认包含对象信息卡、步骤条、表单分组、批量导入导出辅助区和固定动作区，减少业务页面二次排版。}}"
                  [FLEX: form_header_badges]
                    ATTR: Gap(2), Align("Center"), Wrap(true)
                    [BADGE: form_mode_badge]
                      ATTR: Variant("Default")
                      CONTENT: "{{form.mode|标准录入}}"
                    [BADGE: form_wizard_badge]
                      ATTR: Variant("Outline")
                      CONTENT: "向导兼容"
                    [BADGE: form_import_badge]
                      ATTR: Variant("Secondary")
                      CONTENT: "导入导出兼容"

              [STACK: form_draft_panel]
                ATTR: Gap(4)
                [CARD: form_draft_card]
                  ATTR: Id("form_draft_section"), Variant("fit365-soft")
                  [CARD_HEADER: form_draft_header]
                    [CARD_TITLE: form_draft_title]
                      CONTENT: "草稿状态"
                    [CARD_DESCRIPTION: form_draft_description]
                      CONTENT: "顶部统一暴露进度与审核状态。"
                  [CARD_CONTENT: form_draft_content]
                    ATTR: ClassName("space-y-4")
                    [TEXT: form_draft_status]
                      ATTR: Variant("Title"), ClassName("text-2xl")
                      CONTENT: "{{form.status|待提交}}"
                    [PROGRESS: form_draft_progress]
                      ATTR: Value("{{form.progress|58}}")
                    [FLEX: form_draft_meta]
                      ATTR: Justify("Between"), Align("Center")
                      [TEXT: form_draft_meta_label]
                        ATTR: Variant("Muted")
                        CONTENT: "缺失字段"
                      [TEXT: form_draft_meta_value]
                        ATTR: ClassName("font-medium text-[var(--color-primary-dark-2)]")
                        CONTENT: "{{form.missing_count|3}} 项"

    [SECTION: form_progress_section]
      ATTR: Id("form_progress_section"), Layout("none")
      [CARD: form_progress_card]
        ATTR: Variant("fit365-panel")
        [CARD_HEADER: form_progress_header]
          [CARD_TITLE: form_progress_title]
            CONTENT: "流程步骤"
          [CARD_DESCRIPTION: form_progress_description]
            CONTENT: "wizard 变体默认继承同一视觉骨架。"
        [CARD_CONTENT: form_progress_content]
          ATTR: ClassName("space-y-4")
          [STEPPER: form_progress_stepper]
            ATTR: CurrentStep("{{form.current_step|2}}")
            [STEP: form_step_basic]
              ATTR: Title("基本信息"), Description("填写申请人、行程与预算")
            [STEP: form_step_policy]
              ATTR: Title("政策校验"), Description("自动校验标准、超标与备注")
            [STEP: form_step_submit]
              ATTR: Title("提交审批"), Description("生成审批流并推送处理人")

    [SECTION: form_body_section]
      ATTR: Id("form_body_section"), Layout("none")
      [GRID: form_main_grid]
        ATTR: Id("form_main_grid"), Columns(3), Gap(6)

        [STACK: form_main_stack]
          ATTR: ClassName("lg:col-span-2 space-y-6")

          [CARD: form_profile_section]
            ATTR: Variant("fit365-panel")
            [CARD_HEADER: form_object_header]
              [CARD_TITLE: form_object_title]
                CONTENT: "申请对象"
              [CARD_DESCRIPTION: form_object_description]
                CONTENT: "对象型表单默认先展示申请主体与流程上下文。"
            [CARD_CONTENT: form_object_content]
              [GRID: form_object_grid]
                ATTR: Columns(2), Gap(4)
                [CARD: form_object_field_card_1]
                  ATTR: Variant("fit365-muted")
                  [CARD_CONTENT: form_object_field_content_1]
                    ATTR: ClassName("px-5 py-4")
                    [STACK: form_object_field_stack_1]
                      ATTR: Gap(1)
                      [TEXT: form_object_label_1]
                        ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em]")
                        CONTENT: "申请单号"
                      [TEXT: form_object_value_1]
                        ATTR: Variant("Title")
                        CONTENT: "{{form.code|TA-2026-0018}}"
                [CARD: form_object_field_card_2]
                  ATTR: Variant("fit365-muted")
                  [CARD_CONTENT: form_object_field_content_2]
                    ATTR: ClassName("px-5 py-4")
                    [STACK: form_object_field_stack_2]
                      ATTR: Gap(1)
                      [TEXT: form_object_label_2]
                        ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em]")
                        CONTENT: "所属部门"
                      [TEXT: form_object_value_2]
                        ATTR: Variant("Title")
                        CONTENT: "{{form.department|解决方案部}}"
                [CARD: form_object_field_card_3]
                  ATTR: Variant("fit365-muted")
                  [CARD_CONTENT: form_object_field_content_3]
                    ATTR: ClassName("px-5 py-4")
                    [STACK: form_object_field_stack_3]
                      ATTR: Gap(1)
                      [TEXT: form_object_label_3]
                        ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em]")
                        CONTENT: "预算上限"
                      [TEXT: form_object_value_3]
                        ATTR: Variant("Title")
                        CONTENT: "{{form.budget_limit|CNY 15,000}}"
                [CARD: form_object_field_card_4]
                  ATTR: Variant("fit365-soft")
                  [CARD_CONTENT: form_object_field_content_4]
                    ATTR: ClassName("px-5 py-4")
                    [STACK: form_object_field_stack_4]
                      ATTR: Gap(1)
                      [TEXT: form_object_label_4]
                        ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.22em] text-[var(--color-primary-dark-2)]")
                        CONTENT: "政策风险"
                      [TEXT: form_object_value_4]
                        ATTR: Variant("Title"), ClassName("text-[var(--color-primary-dark-2)]")
                        CONTENT: "{{form.policy_risk|需填写超标说明}}"

          [SECTION: form_section]
            [CARD: form_group_section]
              ATTR: Variant("fit365-panel")
              [CARD_HEADER: form_entry_header]
                [CARD_TITLE: form_entry_title]
                  CONTENT: "申请信息"
                [CARD_DESCRIPTION: form_entry_description]
                  CONTENT: "默认提供留白、分组标题和按钮区对齐。"
              [CARD_CONTENT: form_entry_content]
                ATTR: ClassName("space-y-6")
                [FORM: form_entry_form]
                  ATTR: Change("travel_form_change"), Input("travel_form_input"), Submit("travel_form_submit"), ClassName("space-y-6")

                  [GRID: form_entry_grid]
                    ATTR: Columns(2), Gap(4)
                    [STACK: form_entry_field_stack_1]
                      ATTR: Gap(2)
                      [LABEL: form_entry_label_1]
                        CONTENT: "申请主题"
                      [INPUT: form_entry_title_input]
                        ATTR: name("title"), placeholder("请输入申请主题"), value("{{form.fields.title|北京客户拜访}}")
                    [STACK: form_entry_field_stack_2]
                      ATTR: Gap(2)
                      [LABEL: form_entry_label_2]
                        CONTENT: "出行人"
                      [INPUT: form_entry_traveler_input]
                        ATTR: name("traveler"), placeholder("请输入出行人"), value("{{form.fields.traveler|王博}}")
                    [STACK: form_entry_field_stack_3]
                      ATTR: Gap(2)
                      [LABEL: form_entry_label_3]
                        CONTENT: "出发城市"
                      [INPUT: form_entry_origin_input]
                        ATTR: name("origin"), placeholder("请输入出发城市"), value("{{form.fields.origin|上海}}")
                    [STACK: form_entry_field_stack_4]
                      ATTR: Gap(2)
                      [LABEL: form_entry_label_4]
                        CONTENT: "目的城市"
                      [INPUT: form_entry_destination_input]
                        ATTR: name("destination"), placeholder("请输入目的城市"), value("{{form.fields.destination|北京}}")

                  [GRID: form_entry_sub_grid]
                    ATTR: Columns(2), Gap(4)
                    [STACK: form_entry_field_stack_5]
                      ATTR: Gap(2)
                      [LABEL: form_entry_label_5]
                        CONTENT: "出差天数"
                      [INPUT: form_entry_days_input]
                        ATTR: name("days"), type("number"), value("{{form.fields.days|3}}")
                    [STACK: form_entry_field_stack_6]
                      ATTR: Gap(2)
                      [LABEL: form_entry_label_6]
                        CONTENT: "是否加急"
                      [FLEX: form_entry_urgent_row]
                        ATTR: Gap(3), Align("Center")
                        [SWITCH: form_entry_urgent_switch]
                          ATTR: name("urgent"), checked("{{form.fields.urgent|true}}")
                        [TEXT: form_entry_urgent_text]
                          ATTR: ClassName("text-sm text-[var(--color-text-secondary)]")
                          CONTENT: "开启后自动提升审批优先级"

                  [STACK: form_entry_field_stack_7]
                    ATTR: Gap(2)
                    [LABEL: form_entry_label_7]
                      CONTENT: "出行说明"
                    [TEXTAREA: form_entry_reason_textarea]
                      ATTR: name("reason"), Placeholder("补充客户背景、拜访目标和政策说明"), Rows(5)

                  [STACK: form_policy_stack]
                    ATTR: Gap(3)
                    [TEXT: form_policy_title]
                      ATTR: Variant("Title"), ClassName("text-lg")
                      CONTENT: "政策补充"
                    [RADIO_GROUP: form_policy_radio]
                      ATTR: DefaultValue("standard")
                      [FLEX: form_policy_standard_row]
                        ATTR: Gap(2), Align("Center")
                        [RADIO_GROUP_ITEM: form_policy_standard_item]
                          ATTR: Value("standard"), Id("policy-standard")
                        [LABEL: form_policy_standard_label]
                          ATTR: HtmlFor("policy-standard")
                          CONTENT: "符合标准"
                    [FLEX: form_policy_exception_row]
                      ATTR: Gap(2), Align("Center")
                      [RADIO_GROUP_ITEM: form_policy_exception_item]
                        ATTR: Value("exception"), Id("policy-exception")
                      [LABEL: form_policy_exception_label]
                        ATTR: HtmlFor("policy-exception")
                        CONTENT: "存在超标，需要说明"
                  [FLEX: form_policy_notify_row]
                    ATTR: Gap(3), Align("Center")
                    [CHECKBOX: form_policy_notify_checkbox]
                      ATTR: Id("policy-notify"), Checked("true")
                    [LABEL: form_policy_notify_label]
                      ATTR: HtmlFor("policy-notify")
                      CONTENT: "同步通知直属主管和行政支持"

          [CARD: form_import_export_section]
            ATTR: ClassName("border border-dashed border-[var(--color-primary-light-1)] bg-[var(--color-primary-light-2)]")
            [CARD_HEADER: form_import_export_header]
              [CARD_TITLE: form_import_export_title]
                CONTENT: "批量导入 / 导出辅助"
              [CARD_DESCRIPTION: form_import_export_description]
                CONTENT: "import_export 变体共享同一层次结构，仅替换中间交互。"
            [CARD_CONTENT: form_import_export_content]
              ATTR: ClassName("space-y-4")
              [TEXT: form_import_export_text]
                ATTR: Variant("Muted")
                CONTENT: "默认预留模板下载、批量校验与导入结果反馈区域。"
              [FLEX: form_import_export_actions]
                ATTR: Gap(3), Align("Center"), Wrap(true)
                [BUTTON: form_download_template]
                  ATTR: Variant("Outline"), Size("Medium"), Click("download_template")
                  CONTENT: "下载模板"
                [BUTTON: form_bulk_import]
                  ATTR: Variant("Secondary"), Size("Medium"), Click("bulk_import")
                  CONTENT: "导入数据"
                [BUTTON: form_export_preview]
                  ATTR: Variant("Ghost"), Size("Medium"), Click("export_preview")
                  CONTENT: "导出预览"

        [STACK: form_side_stack]
          ATTR: Gap(6)

          [CARD: form_sidebar_section]
            ATTR: ClassName("border border-[var(--color-border-base)] bg-[var(--color-bg-card)]")
            [CARD_HEADER: form_checklist_header]
              [CARD_TITLE: form_checklist_title]
                CONTENT: "提交清单"
              [CARD_DESCRIPTION: form_checklist_description]
                CONTENT: "固定右侧辅助区，统一承载提醒与说明。"
            [CARD_CONTENT: form_checklist_content]
              ATTR: ClassName("space-y-3")
              [FLEX: form_checklist_row_1]
                ATTR: Justify("Between"), Align("Center")
                [TEXT: form_checklist_label_1]
                  ATTR: Variant("Muted")
                  CONTENT: "基础字段"
                [BADGE: form_checklist_badge_1]
                  ATTR: Variant("Secondary")
                  CONTENT: "已完成"
              [FLEX: form_checklist_row_2]
                ATTR: Justify("Between"), Align("Center")
                [TEXT: form_checklist_label_2]
                  ATTR: Variant("Muted")
                  CONTENT: "政策说明"
                [BADGE: form_checklist_badge_2]
                  ATTR: Variant("Outline")
                  CONTENT: "待补充"
              [FLEX: form_checklist_row_3]
                ATTR: Justify("Between"), Align("Center")
                [TEXT: form_checklist_label_3]
                  ATTR: Variant("Muted")
                  CONTENT: "审批对象"
                [BADGE: form_checklist_badge_3]
                  ATTR: Variant("Secondary")
                  CONTENT: "已就绪"

          [SECTION: form_footer]
            ATTR: Id("form_footer"), Layout("none")
            [CARD: form_actions_section]
              ATTR: ClassName("border border-[var(--color-primary-dark-2)] bg-[var(--color-primary-dark-2)] text-white")
              [CARD_HEADER: form_action_header]
                [CARD_TITLE: form_action_title]
                  CONTENT: "操作区"
                [CARD_DESCRIPTION: form_action_description]
                  CONTENT: "表单页默认提供保存、校验、提交三级动作。"
              [CARD_CONTENT: form_action_content]
                ATTR: ClassName("space-y-3")
                [BUTTON: form_validate_btn]
                  ATTR: Variant("Secondary"), Size("Medium"), Click("validate_form"), ClassName("w-full justify-center")
                  CONTENT: "先做校验"
                [BUTTON: form_save_draft_btn]
                  ATTR: Variant("Outline"), Size("Medium"), Click("save_draft"), ClassName("w-full justify-center")
                  CONTENT: "保存草稿"
                [BUTTON: form_submit_btn]
                  ATTR: Variant("Primary"), Size("Medium"), type("submit"), Click("travel_form_submit"), ClassName("w-full justify-center")
                  CONTENT: "提交审批"
