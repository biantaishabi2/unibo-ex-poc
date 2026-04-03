[PAGE: base_overview]
  ATTR: Title("概览面板"), FullHeight(true), Padding(0), Variant("fit365-canvas")

  [CONTAINER: overview_shell]
    ATTR: Size("XLarge"), Variant("fit365-page-shell")

    [SECTION: kpi_cards]
      ATTR: Title("经营总览"), Description("默认企业概览模板，兼容 portal/dashboard 场景"), Layout("none")
      [CARD: overview_hero]
        ATTR: Variant("fit365-hero"), ClassName("overflow-hidden")
        [CARD_CONTENT: overview_hero_content]
          ATTR: ClassName("px-8 py-8 md:px-10 md:py-10")
          [COLUMNS: overview_hero_split]
            { Gap: "6" }
            ATTR: Layout("3:2")
            [STACK: overview_hero_copy]
              ATTR: Gap(4)
              [BADGE: overview_hero_badge]
                ATTR: Variant("Secondary"), ClassName("w-fit border-white/20 bg-white/15 text-white")
                CONTENT: "{{hero_badge|ENTERPRISE OVERVIEW}}"
              [TEXT: overview_hero_title]
                ATTR: Variant("Title"), ClassName("text-3xl font-semibold tracking-tight text-white md:text-4xl")
                CONTENT: "{{hero_title|企业经营驾驶舱}}"
              [TEXT: overview_hero_desc]
                ATTR: Variant("Muted"), ClassName("max-w-2xl text-sm leading-7 text-white/80 md:text-base")
                CONTENT: "{{hero_desc|统一承接门户首页、业务概览与多实体经营看板，突出关键指标、异常提醒与组织动作。}}"
              [FLEX: overview_hero_actions]
                ATTR: Gap(3), Align("Center"), Wrap(true)
                [BUTTON: hero_primary_action]
                ATTR: Variant("Primary"), Click("hero_primary_action"), ClassName("bg-white text-[var(--color-primary-dark-2)] hover:bg-[var(--color-primary-light-2)]")
                  CONTENT: "{{hero_primary_action|进入今日任务}}"
                [BUTTON: hero_secondary_action]
                ATTR: Variant("Outline"), Click("hero_secondary_action"), ClassName("border-white/25 bg-white/10 text-white hover:bg-white/15")
                  CONTENT: "{{hero_secondary_action|查看经营周报}}"
            [GRID: overview_hero_signal_grid]
              { Columns: 2, Gap: 3 }
              [CARD: overview_signal_card_1]
                ATTR: Variant("fit365-soft"), ClassName("rounded-2xl backdrop-blur-sm")
                [CARD_CONTENT: overview_signal_content_1]
                  ATTR: ClassName("space-y-2 px-5 py-5")
                  [TEXT: signal_label_1]
                    ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.18em] text-[var(--color-primary-dark-1)]")
                    CONTENT: "{{signal_label_1|本周产能利用}}"
                  [TEXT: signal_value_1]
                    ATTR: Variant("Title"), ClassName("text-3xl font-semibold text-[var(--color-text-base)]")
                    CONTENT: "{{signal_value_1|86%}}"
                  [TEXT: signal_desc_1]
                    ATTR: Variant("Muted"), ClassName("text-xs text-[var(--color-text-secondary)]")
                    CONTENT: "{{signal_desc_1|较上周提升 4.8%}}"
              [CARD: overview_signal_card_2]
                ATTR: Variant("fit365-soft"), ClassName("rounded-2xl backdrop-blur-sm")
                [CARD_CONTENT: overview_signal_content_2]
                  ATTR: ClassName("space-y-2 px-5 py-5")
                  [TEXT: signal_label_2]
                    ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.18em] text-[var(--color-primary-dark-1)]")
                    CONTENT: "{{signal_label_2|待处理风险}}"
                  [TEXT: signal_value_2]
                    ATTR: Variant("Title"), ClassName("text-3xl font-semibold text-[var(--color-text-base)]")
                    CONTENT: "{{signal_value_2|07}}"
                  [TEXT: signal_desc_2]
                    ATTR: Variant("Muted"), ClassName("text-xs text-[var(--color-text-secondary)]")
                    CONTENT: "{{signal_desc_2|2 项需要 24h 内闭环}}"
              [CARD: overview_signal_card_3]
                ATTR: Variant("fit365-soft"), ClassName("rounded-2xl backdrop-blur-sm")
                [CARD_CONTENT: overview_signal_content_3]
                  ATTR: ClassName("space-y-2 px-5 py-5")
                  [TEXT: signal_label_3]
                    ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.18em] text-[var(--color-primary-dark-1)]")
                    CONTENT: "{{signal_label_3|协同任务}}"
                  [TEXT: signal_value_3]
                    ATTR: Variant("Title"), ClassName("text-3xl font-semibold text-[var(--color-text-base)]")
                    CONTENT: "{{signal_value_3|124}}"
                  [TEXT: signal_desc_3]
                    ATTR: Variant("Muted"), ClassName("text-xs text-[var(--color-text-secondary)]")
                    CONTENT: "{{signal_desc_3|含 18 项跨部门依赖}}"
              [CARD: overview_signal_card_4]
                ATTR: Variant("fit365-soft"), ClassName("rounded-2xl backdrop-blur-sm")
                [CARD_CONTENT: overview_signal_content_4]
                  ATTR: ClassName("space-y-2 px-5 py-5")
                  [TEXT: signal_label_4]
                    ATTR: Variant("Muted"), ClassName("text-xs uppercase tracking-[0.18em] text-[var(--color-primary-dark-1)]")
                    CONTENT: "{{signal_label_4|预算健康度}}"
                  [TEXT: signal_value_4]
                    ATTR: Variant("Title"), ClassName("text-3xl font-semibold text-[var(--color-text-base)]")
                    CONTENT: "{{signal_value_4|92分}}"
                  [TEXT: signal_desc_4]
                    ATTR: Variant("Muted"), ClassName("text-xs text-[var(--color-text-secondary)]")
                    CONTENT: "{{signal_desc_4|支出与计划基本对齐}}"

      [GRID: kpi_grid]
        { Columns: 4, Gap: 4 }
        [CARD: kpi_card_1]
          ATTR: Variant("fit365-shell")
          [CARD_CONTENT: kpi_1_content]
            ATTR: ClassName("space-y-4 px-6 py-6")
            [FLEX: kpi_1_header]
              ATTR: Justify("Between"), Align("Center")
              [TEXT: kpi_1_label]
                ATTR: Variant("Muted"), ClassName("text-xs font-medium uppercase tracking-[0.18em]")
                CONTENT: "{{kpi_1_label|收入达成}}"
              [BADGE: kpi_1_badge]
                ATTR: Variant("Secondary")
                CONTENT: "{{kpi_1_badge|本月}}"
            [TEXT: kpi_1_value]
              ATTR: Variant("Title"), ClassName("text-3xl font-semibold tracking-tight")
              CONTENT: "{{kpi_1_value|¥12.8M}}"
            [PROGRESS: kpi_1_progress]
              ATTR: Value("78")
            [TEXT: kpi_1_trend]
              ATTR: Variant("Caption"), ClassName("text-emerald-600")
              CONTENT: "{{kpi_1_trend|目标完成度 +9.2%}}"
        [CARD: kpi_card_2]
          ATTR: Variant("fit365-shell")
          [CARD_CONTENT: kpi_2_content]
            ATTR: ClassName("space-y-4 px-6 py-6")
            [FLEX: kpi_2_header]
              ATTR: Justify("Between"), Align("Center")
              [TEXT: kpi_2_label]
                ATTR: Variant("Muted"), ClassName("text-xs font-medium uppercase tracking-[0.18em]")
                CONTENT: "{{kpi_2_label|服务交付}}"
              [BADGE: kpi_2_badge]
                ATTR: Variant("Secondary")
                CONTENT: "{{kpi_2_badge|SLA}}"
            [TEXT: kpi_2_value]
              ATTR: Variant("Title"), ClassName("text-3xl font-semibold tracking-tight")
              CONTENT: "{{kpi_2_value|98.4%}}"
            [PROGRESS: kpi_2_progress]
              ATTR: Value("98")
            [TEXT: kpi_2_trend]
              ATTR: Variant("Caption"), ClassName("text-emerald-600")
              CONTENT: "{{kpi_2_trend|连续 6 周稳定}}"
        [CARD: kpi_card_3]
          ATTR: Variant("fit365-shell")
          [CARD_CONTENT: kpi_3_content]
            ATTR: ClassName("space-y-4 px-6 py-6")
            [FLEX: kpi_3_header]
              ATTR: Justify("Between"), Align("Center")
              [TEXT: kpi_3_label]
                ATTR: Variant("Muted"), ClassName("text-xs font-medium uppercase tracking-[0.18em]")
                CONTENT: "{{kpi_3_label|客户留存}}"
              [BADGE: kpi_3_badge]
                ATTR: Variant("Secondary")
                CONTENT: "{{kpi_3_badge|季度}}"
            [TEXT: kpi_3_value]
              ATTR: Variant("Title"), ClassName("text-3xl font-semibold tracking-tight")
              CONTENT: "{{kpi_3_value|91.6%}}"
            [PROGRESS: kpi_3_progress]
              ATTR: Value("92")
            [TEXT: kpi_3_trend]
              ATTR: Variant("Caption"), ClassName("text-sky-600")
              CONTENT: "{{kpi_3_trend|重点客户续约率良好}}"
        [CARD: kpi_card_4]
          ATTR: Variant("fit365-shell")
          [CARD_CONTENT: kpi_4_content]
            ATTR: ClassName("space-y-4 px-6 py-6")
            [FLEX: kpi_4_header]
              ATTR: Justify("Between"), Align("Center")
              [TEXT: kpi_4_label]
                ATTR: Variant("Muted"), ClassName("text-xs font-medium uppercase tracking-[0.18em]")
                CONTENT: "{{kpi_4_label|组织活跃}}"
              [BADGE: kpi_4_badge]
                ATTR: Variant("Secondary")
                CONTENT: "{{kpi_4_badge|协同}}"
            [TEXT: kpi_4_value]
              ATTR: Variant("Title"), ClassName("text-3xl font-semibold tracking-tight")
              CONTENT: "{{kpi_4_value|1,284}}"
            [PROGRESS: kpi_4_progress]
              ATTR: Value("64")
            [TEXT: kpi_4_trend]
              ATTR: Variant("Caption"), ClassName("text-amber-600")
              CONTENT: "{{kpi_4_trend|仍有 36% 空间待激活}}"

    [SECTION: charts]
      ATTR: Title("经营洞察"), Description("趋势、结构与异常提醒的默认组合"), Layout("none")
      [GRID: chart_grid]
        { Columns: 2, Gap: 4 }
        [CARD: chart_card_1]
          ATTR: Variant("fit365-shell")
          [CARD_HEADER: chart_1_header]
            ATTR: ClassName("px-6 pt-6")
            [FLEX: chart_1_heading]
              ATTR: Justify("Between"), Align("Center")
              [STACK: chart_1_copy]
                ATTR: Gap(1)
                [CARD_TITLE: chart_1_title]
                  CONTENT: "{{chart_1_title|经营趋势}}"
                [CARD_DESCRIPTION: chart_1_desc]
                  CONTENT: "{{chart_1_desc|收入、交付与风险处置保持同屏观察}}"
              [BADGE: chart_1_badge]
                ATTR: Variant("Outline")
                CONTENT: "{{chart_1_badge|近 30 天}}"
          [CARD_CONTENT: chart_1_content]
            ATTR: ClassName("space-y-5 px-6 pb-6")
            [DIV: chart_1_placeholder]
              ATTR: ClassName("rounded-[24px] border border-dashed border-[var(--color-primary-light-1)] bg-[linear-gradient(135deg,var(--color-primary-dark-2)_0%,var(--color-primary-dark-1)_55%,var(--color-primary)_100%)] px-6 py-6 text-white")
              [STACK: chart_1_layers]
                ATTR: Gap(4)
                [TEXT: chart_1_summary]
                  ATTR: Variant("Body"), ClassName("text-sm text-white/80")
                  CONTENT: "{{chart_1_summary|默认保留图表承载区，可直接替换为真实 chart runtime。}}"
                [GRID: chart_1_metrics]
                  { Columns: 3, Gap: 3 }
                  [CARD: chart_1_metric_a]
                    ATTR: ClassName("border-white/15 bg-white/10 shadow-none")
                    [CARD_CONTENT: chart_1_metric_a_content]
                      ATTR: ClassName("space-y-1 px-4 py-4")
                      [TEXT: chart_1_metric_a_label]
                        ATTR: Variant("Caption"), ClassName("text-white/70")
                        CONTENT: "收入"
                      [TEXT: chart_1_metric_a_value]
                        ATTR: Variant("Title"), ClassName("text-2xl text-white")
                        CONTENT: "12.8M"
                  [CARD: chart_1_metric_b]
                    ATTR: ClassName("border-white/15 bg-white/10 shadow-none")
                    [CARD_CONTENT: chart_1_metric_b_content]
                      ATTR: ClassName("space-y-1 px-4 py-4")
                      [TEXT: chart_1_metric_b_label]
                        ATTR: Variant("Caption"), ClassName("text-white/70")
                        CONTENT: "交付"
                      [TEXT: chart_1_metric_b_value]
                        ATTR: Variant("Title"), ClassName("text-2xl text-white")
                        CONTENT: "98.4%"
                  [CARD: chart_1_metric_c]
                    ATTR: ClassName("border-white/15 bg-white/10 shadow-none")
                    [CARD_CONTENT: chart_1_metric_c_content]
                      ATTR: ClassName("space-y-1 px-4 py-4")
                      [TEXT: chart_1_metric_c_label]
                        ATTR: Variant("Caption"), ClassName("text-white/70")
                        CONTENT: "风险"
                      [TEXT: chart_1_metric_c_value]
                        ATTR: Variant("Title"), ClassName("text-2xl text-white")
                        CONTENT: "07"
                [TEXT: chart_1_footer]
                  ATTR: Variant("Caption"), ClassName("text-white/60")
                  CONTENT: "{{chart_1_footer|图表接入后可将该区域替换为趋势线、面积图或混合分析图。}}"
        [CARD: chart_card_2]
          ATTR: Variant("fit365-shell")
          [CARD_HEADER: chart_2_header]
            ATTR: ClassName("px-6 pt-6")
            [CARD_TITLE: chart_2_title]
              CONTENT: "{{chart_2_title|结构与提醒}}"
            [CARD_DESCRIPTION: chart_2_desc]
              CONTENT: "{{chart_2_desc|右侧板块用于经营结构、预警与资源分布摘要}}"
          [CARD_CONTENT: chart_2_content]
            ATTR: ClassName("space-y-5 px-6 pb-6")
            [CARD: chart_2_mix_card]
              ATTR: Variant("fit365-soft")
              [CARD_CONTENT: chart_2_mix_content]
                ATTR: ClassName("space-y-4 px-5 py-5")
                [TEXT: chart_2_placeholder]
                  ATTR: Variant("Body"), ClassName("text-sm text-[var(--color-text-secondary)]")
                  CONTENT: "{{chart_2_placeholder|默认展示结构占比、预警清单或业务分布摘要。}}"
                [STACK: chart_2_distribution]
                  ATTR: Gap(3)
                  [FLEX: chart_2_item_a]
                    ATTR: Justify("Between"), Align("Center")
                    [TEXT: chart_2_item_a_label]
                      CONTENT: "核心业务"
                    [BADGE: chart_2_item_a_value]
                      CONTENT: "46%"
                  [PROGRESS: chart_2_progress_a]
                    ATTR: Value("46")
                  [FLEX: chart_2_item_b]
                    ATTR: Justify("Between"), Align("Center")
                    [TEXT: chart_2_item_b_label]
                      CONTENT: "增量业务"
                    [BADGE: chart_2_item_b_value]
                      CONTENT: "31%"
                  [PROGRESS: chart_2_progress_b]
                    ATTR: Value("31")
                  [FLEX: chart_2_item_c]
                    ATTR: Justify("Between"), Align("Center")
                    [TEXT: chart_2_item_c_label]
                      CONTENT: "风险暴露"
                    [BADGE: chart_2_item_c_value]
                      ATTR: Variant("Outline")
                      CONTENT: "23%"
                  [PROGRESS: chart_2_progress_c]
                    ATTR: Value("23")
            [CARD: chart_2_alerts]
              ATTR: Variant("fit365-soft")
              [CARD_CONTENT: chart_2_alerts_content]
                ATTR: ClassName("space-y-3 px-5 py-5")
                [TEXT: chart_2_alerts_title]
                  ATTR: Variant("Body"), ClassName("font-semibold text-amber-900")
                  CONTENT: "今日经营提醒"
                [TEXT: chart_2_alert_1]
                  ATTR: Variant("Caption"), ClassName("text-amber-900")
                  CONTENT: "华东产线排班存在瓶颈，建议优先补位。"
                [TEXT: chart_2_alert_2]
                  ATTR: Variant("Caption"), ClassName("text-amber-900")
                  CONTENT: "3 个高优工单待审批，预计影响明早交付。"
                [TEXT: chart_2_alert_3]
                  ATTR: Variant("Caption"), ClassName("text-amber-900")
                  CONTENT: "预算执行偏差已收敛，可继续推进本周项目。"

    [SECTION: activity_feed]
      ATTR: Title("动态与动作"), Description("默认保留动态流与快捷动作的双栏组合"), Layout("none")
      [GRID: bottom_grid]
        { Columns: 2, Gap: 4 }
        [CARD: feed_card]
          ATTR: Variant("fit365-shell")
          [CARD_HEADER: feed_header]
            ATTR: ClassName("px-6 pt-6")
            [CARD_TITLE: feed_title]
              CONTENT: "最新动态"
            [CARD_DESCRIPTION: feed_desc]
              CONTENT: "承接事件流、审批流与组织更新信息"
          [CARD_CONTENT: feed_content]
            ATTR: ClassName("px-6 pb-6")
            [STACK: feed_list]
              ATTR: Gap(3)
              [FOR: item in feed_items]
                [CARD: feed_item_card]
                  ATTR: Variant("fit365-soft")
                  [CARD_CONTENT: feed_item_content]
                    ATTR: ClassName("px-4 py-4")
                    [FLEX: feed_item]
                      ATTR: Justify("Between"), Align("Center"), ClassName("gap-4")
                      [STACK: feed_item_texts]
                        ATTR: Gap(1)
                        [TEXT: feed_text]
                          CONTENT: "{{item.text|审批节点已更新，等待负责人确认。}}"
                        [TEXT: feed_subtext]
                          ATTR: Variant("Caption"), ClassName("text-[var(--color-text-tertiary)]")
                          CONTENT: "{{item.meta|默认动态摘要}}"
                      [TEXT: feed_time]
                        ATTR: Variant("Caption"), ClassName("whitespace-nowrap text-[var(--color-text-tertiary)]")
                        CONTENT: "{{item.time|5 分钟前}}"
              [/FOR]
        [CARD: quick_actions_card]
          ATTR: Variant("fit365-shell")
          [CARD_HEADER: quick_actions_header]
            ATTR: ClassName("px-6 pt-6")
            [CARD_TITLE: quick_actions_title]
              CONTENT: "快捷动作"
            [CARD_DESCRIPTION: quick_actions_desc]
              CONTENT: "适合作为 portal 与 dashboard 场景的二级操作区"
          [CARD_CONTENT: quick_actions_content]
            ATTR: ClassName("space-y-5 px-6 pb-6")
            [GRID: action_grid]
              { Columns: 2, Gap: 3 }
              [BUTTON: quick_action_1]
                ATTR: Variant("Secondary"), Click("quick_action_1"), ClassName("h-24 justify-start rounded-[20px] border border-[var(--color-primary-light-1)] bg-[var(--color-primary-light-2)] px-5 text-left")
                CONTENT: "{{action_1_label|发起经营复盘}}"
              [BUTTON: quick_action_2]
                ATTR: Variant("Secondary"), Click("quick_action_2"), ClassName("h-24 justify-start rounded-[20px] border border-[var(--color-primary-light-1)] bg-[var(--color-primary-light-2)] px-5 text-left")
                CONTENT: "{{action_2_label|查看风险台账}}"
              [BUTTON: quick_action_3]
                ATTR: Variant("Secondary"), Click("quick_action_3"), ClassName("h-24 justify-start rounded-[20px] border border-[var(--color-primary-light-1)] bg-[var(--color-primary-light-2)] px-5 text-left")
                CONTENT: "{{action_3_label|同步部门指标}}"
              [BUTTON: quick_action_4]
                ATTR: Variant("Secondary"), Click("quick_action_4"), ClassName("h-24 justify-start rounded-[20px] border border-[var(--color-primary-light-1)] bg-[var(--color-primary-light-2)] px-5 text-left")
                CONTENT: "{{action_4_label|导出周报摘要}}"
            [CARD: quick_actions_briefing]
              ATTR: Variant("fit365-soft")
              [CARD_CONTENT: quick_actions_briefing_content]
                ATTR: ClassName("space-y-2 px-5 py-5")
                [TEXT: quick_actions_briefing_title]
                  ATTR: Variant("Body"), ClassName("font-semibold")
                  CONTENT: "班前简报"
                [TEXT: quick_actions_briefing_text]
                  ATTR: Variant("Caption"), ClassName("text-[var(--color-text-secondary)]")
                  CONTENT: "默认结构强调概览后的行动入口，避免页面只停留在 KPI 展示层。"
