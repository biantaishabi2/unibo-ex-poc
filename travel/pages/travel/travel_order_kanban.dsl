# 出差订单看板
# 按状态分列展示出差订单，支持拖拽变更状态

EXTENDS: base_kanban
META: Entity("TravelOrder"), Domain("Travel"), Display("kanban")

[PAGE: travel_order_kanban]
  ATTR: Title("出差订单看板")
