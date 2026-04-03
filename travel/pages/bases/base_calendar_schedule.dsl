[PAGE: base_calendar_schedule]
  ATTR: Title("排期"), FullHeight(true), Padding(0), Variant("fit365-canvas")

  [CONTAINER: calendar_shell]
    ATTR: Size("XLarge"), Variant("fit365-page-shell-compact")

    [SECTION: date_nav_section]
      ATTR: Layout("none")
      [CARD: date_nav_card]
        ATTR: Variant("fit365-hero"), ClassName("overflow-hidden")
        [CARD_CONTENT: date_nav_card_content]
          ATTR: ClassName("space-y-5 px-8 py-7")
          [FLEX: date_navigator]
            ATTR: Justify("Between"), Align("Center"), ClassName("gap-4")
            [STACK: date_nav_copy]
              ATTR: Gap(2)
              [TEXT: nav_title]
                ATTR: Variant("Title"), ClassName("text-3xl font-semibold tracking-tight text-white")
                CONTENT: "{{nav_title|企业排班指挥台}}"
              [TEXT: nav_subtitle]
                ATTR: Variant("Caption"), ClassName("text-sm text-white/80")
                CONTENT: "{{nav_subtitle|统一承接场地预约、课程排期、活动日历等企业特殊场景。}}"
            [FLEX: date_nav_actions]
              ATTR: Gap(2), Wrap(true)
              [BUTTON: prev_range_btn]
                ATTR: Variant("Ghost"), Click("prev_range"), ClassName("border border-white/15 bg-white/10 text-white hover:bg-white/15")
                CONTENT: "上一周期"
              [BUTTON: today_btn]
                ATTR: Variant("Secondary"), Click("go_today"), ClassName("bg-white text-[var(--color-primary-dark-2)] hover:bg-[var(--color-primary-light-2)]")
                CONTENT: "回到今天"
              [BUTTON: next_range_btn]
                ATTR: Variant("Ghost"), Click("next_range"), ClassName("border border-white/15 bg-white/10 text-white hover:bg-white/15")
                CONTENT: "下一周期"
          [COLUMNS: date_nav_metrics]
            { Gap: "4" }
            ATTR: Layout("2:1:1")
            [CARD: date_nav_brief]
              ATTR: Variant("fit365-soft"), ClassName("rounded-[22px] backdrop-blur-sm")
              [CARD_CONTENT: date_nav_brief_content]
                ATTR: ClassName("space-y-2 px-5 py-5")
                [TEXT: date_nav_brief_title]
                  ATTR: Variant("Body"), ClassName("font-semibold text-[var(--color-text-base)]")
                  CONTENT: "本期排班摘要"
                [TEXT: date_nav_brief_text]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-secondary)]")
                  CONTENT: "默认头部同时承载日期导航、业务状态与跨资源概览。"
            [CARD: date_nav_metric_1]
              ATTR: Variant("fit365-soft"), ClassName("rounded-[22px] backdrop-blur-sm")
              [CARD_CONTENT: date_nav_metric_1_content]
                ATTR: ClassName("space-y-1 px-5 py-5")
                [TEXT: date_nav_metric_1_label]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-primary-dark-1)]")
                  CONTENT: "今日资源"
                [TEXT: date_nav_metric_1_value]
                  ATTR: Variant("Title"), ClassName("text-2xl text-[var(--color-text-base)]")
                  CONTENT: "{{resource_count|26}}"
            [CARD: date_nav_metric_2]
              ATTR: Variant("fit365-soft"), ClassName("rounded-[22px] backdrop-blur-sm")
              [CARD_CONTENT: date_nav_metric_2_content]
                ATTR: ClassName("space-y-1 px-5 py-5")
                [TEXT: date_nav_metric_2_label]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-primary-dark-1)]")
                  CONTENT: "待确认变更"
                [TEXT: date_nav_metric_2_value]
                  ATTR: Variant("Title"), ClassName("text-2xl text-[var(--color-text-base)]")
                  CONTENT: "{{pending_change_count|05}}"

    [SECTION: resource_section]
      ATTR: Layout("none")
      [COLUMNS: resource_layout]
        { Gap: "4" }
        ATTR: Layout("1:2")
        [CARD: resource_filter_card]
          ATTR: Variant("fit365-shell")
          [CARD_HEADER: resource_filter_header]
            ATTR: ClassName("px-6 pt-6")
            [CARD_TITLE: resource_filter_title]
              CONTENT: "资源与筛选"
            [CARD_DESCRIPTION: resource_filter_desc]
              CONTENT: "左侧维持资源导航与筛选集合"
          [CARD_CONTENT: resource_filter_content]
            ATTR: ClassName("space-y-4 px-6 pb-6")
            [FLEX: resource_filter]
              ATTR: Gap(2), Wrap(true)
              [BUTTON: resource_scope_all]
                ATTR: Variant("Secondary"), Click("filter_scope_all")
                CONTENT: "全部资源"
              [BUTTON: resource_scope_core]
                ATTR: Variant("Outline"), Click("filter_scope_core")
                CONTENT: "核心资源"
              [BUTTON: resource_scope_overload]
                ATTR: Variant("Outline"), Click("filter_scope_overload")
                CONTENT: "负载预警"
            [STACK: resource_groups]
              ATTR: Gap(3)
              [CARD: resource_group_a]
                ATTR: Variant("fit365-soft")
                [CARD_CONTENT: resource_group_a_content]
                  ATTR: ClassName("space-y-2 px-4 py-4")
                  [TEXT: resource_group_a_title]
                    ATTR: Variant("Body"), ClassName("font-semibold")
                    CONTENT: "华东区域"
                  [TEXT: resource_group_a_text]
                    ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                    CONTENT: "设备 12 台，班次 32 个"
              [CARD: resource_group_b]
                ATTR: Variant("fit365-soft")
                [CARD_CONTENT: resource_group_b_content]
                  ATTR: ClassName("space-y-2 px-4 py-4")
                  [TEXT: resource_group_b_title]
                    ATTR: Variant("Body"), ClassName("font-semibold")
                    CONTENT: "华南区域"
                  [TEXT: resource_group_b_text]
                    ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                    CONTENT: "设备 08 台，班次 20 个"
        [CARD: resource_summary_card]
          ATTR: Variant("fit365-shell")
          [CARD_HEADER: resource_summary_header]
            ATTR: ClassName("px-6 pt-6")
            [CARD_TITLE: resource_summary_title]
              CONTENT: "班次摘要"
            [CARD_DESCRIPTION: resource_summary_desc]
              CONTENT: "右侧补足筛选后的容量、冲突与空闲信息"
          [CARD_CONTENT: resource_summary_content]
            ATTR: ClassName("space-y-4 px-6 pb-6")
            [GRID: resource_summary_grid]
              { Columns: 3, Gap: 3 }
              [CARD: resource_summary_card_1]
                ATTR: ClassName("rounded-[22px] bg-[var(--color-primary-light-2)] shadow-none")
                [CARD_CONTENT: resource_summary_card_1_content]
                  ATTR: ClassName("space-y-1 px-4 py-4")
                  [TEXT: resource_summary_card_1_label]
                    ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                    CONTENT: "排满"
                  [TEXT: resource_summary_card_1_value]
                    ATTR: Variant("Title"), ClassName("text-2xl")
                    CONTENT: "09"
              [CARD: resource_summary_card_2]
                ATTR: ClassName("rounded-[22px] bg-[var(--color-primary-light-2)] shadow-none")
                [CARD_CONTENT: resource_summary_card_2_content]
                  ATTR: ClassName("space-y-1 px-4 py-4")
                  [TEXT: resource_summary_card_2_label]
                    ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                    CONTENT: "冲突"
                  [TEXT: resource_summary_card_2_value]
                    ATTR: Variant("Title"), ClassName("text-2xl")
                    CONTENT: "03"
              [CARD: resource_summary_card_3]
                ATTR: ClassName("rounded-[22px] bg-[var(--color-primary-light-2)] shadow-none")
                [CARD_CONTENT: resource_summary_card_3_content]
                  ATTR: ClassName("space-y-1 px-4 py-4")
                  [TEXT: resource_summary_card_3_label]
                    ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                    CONTENT: "空闲"
                  [TEXT: resource_summary_card_3_value]
                    ATTR: Variant("Title"), ClassName("text-2xl")
                    CONTENT: "14"
            [TEXT: resource_summary_hint]
              ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
              CONTENT: "可替换为真实资源筛选、标签与容量统计组件。"

    [SECTION: matrix_section]
      ATTR: Layout("none")
      [CARD: matrix_card]
        ATTR: Variant("fit365-shell")
        [CARD_HEADER: matrix_header]
          ATTR: ClassName("px-6 pt-6")
          [FLEX: matrix_header_bar]
            ATTR: Justify("Between"), Align("Center"), ClassName("gap-4")
            [STACK: matrix_header_copy]
              ATTR: Gap(1)
              [CARD_TITLE: matrix_title]
                CONTENT: "时段矩阵"
              [CARD_DESCRIPTION: matrix_desc]
                CONTENT: "中心矩阵区强化时段、资源和冲突的企业视觉层次"
            [FLEX: matrix_header_actions]
              ATTR: Gap(2), Wrap(true)
              [BUTTON: matrix_export_btn]
                ATTR: Variant("Outline"), Click("matrix_export")
                CONTENT: "导出排班"
              [BUTTON: matrix_adjust_btn]
                ATTR: Variant("Secondary"), Click("matrix_adjust")
                CONTENT: "批量调整"
        [CARD_CONTENT: matrix_content]
          ATTR: ClassName("space-y-4 px-6 pb-6")
          [TEXT: slot_matrix_placeholder]
            ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
            CONTENT: "默认矩阵区域可直接替换为真实日历/排期组件，同时保留企业级壳层。"
          [CARD: matrix_surface]
            ATTR: Variant("fit365-soft")
            [CARD_CONTENT: matrix_surface_content]
              ATTR: ClassName("px-4 py-4")
              [TABLE: slot_matrix_table]
                [TABLE_HEADER: slot_matrix_header]
                  [TABLE_ROW: slot_matrix_header_row]
                    [TABLE_HEAD: slot_matrix_head_resource]
                      CONTENT: "资源"
                    [TABLE_HEAD: slot_matrix_head_morning]
                      CONTENT: "08:00"
                    [TABLE_HEAD: slot_matrix_head_noon]
                      CONTENT: "12:00"
                    [TABLE_HEAD: slot_matrix_head_afternoon]
                      CONTENT: "16:00"
                    [TABLE_HEAD: slot_matrix_head_evening]
                      CONTENT: "20:00"
                [TABLE_BODY: slot_matrix_body]
                  [TABLE_ROW: slot_matrix_row_a]
                    [TABLE_CELL: slot_matrix_row_a_resource]
                      CONTENT: "A-101"
                    [TABLE_CELL: slot_matrix_row_a_morning]
                      [BADGE: slot_matrix_badge_a_morning]
                        CONTENT: "满"
                    [TABLE_CELL: slot_matrix_row_a_noon]
                      [BADGE: slot_matrix_badge_a_noon]
                        ATTR: Variant("Outline")
                        CONTENT: "检修"
                    [TABLE_CELL: slot_matrix_row_a_afternoon]
                      [BADGE: slot_matrix_badge_a_afternoon]
                        CONTENT: "满"
                    [TABLE_CELL: slot_matrix_row_a_evening]
                      [BADGE: slot_matrix_badge_a_evening]
                        ATTR: Variant("Secondary")
                        CONTENT: "空闲"
                  [TABLE_ROW: slot_matrix_row_b]
                    [TABLE_CELL: slot_matrix_row_b_resource]
                      CONTENT: "B-204"
                    [TABLE_CELL: slot_matrix_row_b_morning]
                      [BADGE: slot_matrix_badge_b_morning]
                        ATTR: Variant("Secondary")
                        CONTENT: "空闲"
                    [TABLE_CELL: slot_matrix_row_b_noon]
                      [BADGE: slot_matrix_badge_b_noon]
                        CONTENT: "满"
                    [TABLE_CELL: slot_matrix_row_b_afternoon]
                      [BADGE: slot_matrix_badge_b_afternoon]
                        CONTENT: "满"
                    [TABLE_CELL: slot_matrix_row_b_evening]
                      [BADGE: slot_matrix_badge_b_evening]
                        ATTR: Variant("Outline")
                        CONTENT: "预留"
                  [TABLE_ROW: slot_matrix_row_c]
                    [TABLE_CELL: slot_matrix_row_c_resource]
                      CONTENT: "C-301"
                    [TABLE_CELL: slot_matrix_row_c_morning]
                      [BADGE: slot_matrix_badge_c_morning]
                        CONTENT: "满"
                    [TABLE_CELL: slot_matrix_row_c_noon]
                      [BADGE: slot_matrix_badge_c_noon]
                        ATTR: Variant("Secondary")
                        CONTENT: "空闲"
                    [TABLE_CELL: slot_matrix_row_c_afternoon]
                      [BADGE: slot_matrix_badge_c_afternoon]
                        ATTR: Variant("Outline")
                        CONTENT: "冲突"
                    [TABLE_CELL: slot_matrix_row_c_evening]
                      [BADGE: slot_matrix_badge_c_evening]
                        CONTENT: "满"

    [SECTION: summary_section]
      ATTR: Layout("none")
      [CARD: summary_card]
        ATTR: Variant("fit365-shell")
        [CARD_HEADER: summary_header]
          ATTR: ClassName("px-6 pt-6")
          [CARD_TITLE: summary_title]
            CONTENT: "摘要"
          [CARD_DESCRIPTION: summary_desc]
            CONTENT: "默认尾部用于班次提醒、操作建议与排班说明"
        [CARD_CONTENT: summary_content]
          ATTR: ClassName("space-y-4 px-6 pb-6")
          [GRID: summary_grid]
            { Columns: 3, Gap: 3 }
            [CARD: summary_brief_1]
              ATTR: Variant("fit365-soft")
              [CARD_CONTENT: summary_brief_1_content]
                ATTR: ClassName("space-y-2 px-4 py-4")
                [TEXT: summary_brief_1_title]
                  ATTR: Variant("Body"), ClassName("font-semibold")
                  CONTENT: "资源健康"
                [TEXT: summary_brief_1_text]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                  CONTENT: "关键资源利用率 86%，仍可承接夜班需求。"
            [CARD: summary_brief_2]
              ATTR: Variant("fit365-soft")
              [CARD_CONTENT: summary_brief_2_content]
                ATTR: ClassName("space-y-2 px-4 py-4")
                [TEXT: summary_brief_2_title]
                  ATTR: Variant("Body"), ClassName("font-semibold")
                  CONTENT: "冲突提醒"
                [TEXT: summary_brief_2_text]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                  CONTENT: "下午时段有 3 处资源重叠，需要主管确认。"
            [CARD: summary_brief_3]
              ATTR: Variant("fit365-soft")
              [CARD_CONTENT: summary_brief_3_content]
                ATTR: ClassName("space-y-2 px-4 py-4")
                [TEXT: summary_brief_3_title]
                  ATTR: Variant("Body"), ClassName("font-semibold")
                  CONTENT: "排班建议"
                [TEXT: summary_brief_3_text]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                  CONTENT: "建议将 C-301 晚间任务转移到 B-204 预留档。"
