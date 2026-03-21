# 交通搜索结果基础模板
# 适用于机票、火车票等带日期横滑+筛选栏+卡片列表+底部排序栏的搜索结果页
# 酒店搜索结构差异较大，不使用此模板

[PAGE: base_search_results]
  ATTR: Title("搜索结果")

  # 顶部导航
  [SECTION: header_section]
    [HEADER: page_header]
      ATTR: Back(true), Title("搜索")

  # 日期横滑条
  [SECTION: date_slider_section]
    [FLEX: date_slider]
      { Gap: 2, PaddingX: 3, PaddingY: 2, OverflowX: "scroll", Background: "surface" }
      [FOR: date_item in search.date_range]
        [BADGE: date_badge]
          ATTR: Variant("{{date_item.is_selected|}}"), Click("select_date")
          CONTENT: "{{date_item.date_label|}}"
      [/FOR]

  [SEPARATOR: sep_after_date]

  # 筛选栏
  [SECTION: filter_section]
    [FLEX: filter_bar]
      { Gap: 2, PaddingX: 3, PaddingY: 2, Wrap: true }
      # 子类覆写此区域填充具体筛选项

  # 超标提示
  [SECTION: alert_section]
    [IF: policy.exceeded == true]
      [ALERT: policy_alert]
        ATTR: Variant("warning"), Title("超标提示")
        CONTENT: "标记超标的项目超出差旅标准，预订需审批"
    [/IF]

  # 卡片列表
  [SECTION: results_section]
    [STACK: results_list]
      { Gap: 3, Padding: 3 }
      # 子类覆写此区域填充 FOR 循环和卡片

  # 空状态
  [SECTION: empty_section]
    [IF: results.total_count == 0]
      [EMPTY_STATE: no_results]
        ATTR: Title("未找到结果"), Description("请调整搜索条件后重试")
    [/IF]

  # 底部排序栏
  [SECTION: sort_bar_section]
    [CONTROL_BAR: bottom_sort_bar]
      ATTR: Position("sticky_bottom")
      [FLEX: sort_buttons]
        { Gap: 3, Justify: "SpaceAround", Width: "full" }
        # 子类覆写此区域填充具体排序按钮
