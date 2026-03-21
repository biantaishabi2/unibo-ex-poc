# 出差申请页
# 向导模式：4步（基本信息 → 行程安排 → 预算 → 确认提交）

EXTENDS: base_form
META: Entity("TravelOrder"), Domain("Travel"), FormMode("wizard")

[PAGE: travel_request]
  ATTR: Title("出差申请")
