# 酒店搜索结果页
# 按条件搜索酒店列表，支持筛选排序
# 结构与机票/火车票差异较大（无日期横滑、无底部排序栏、有图片卡片），不使用 EXTENDS

EXTENDS: base_list_report
META: Entity("HotelOffer"), Domain("Travel"), Display("card_grid")

[PAGE: hotel_search_results]
  ATTR: Title("酒店搜索")
