# 改签确认页
# 向导模式：3步（选择航班 → 确认差价 → 提交改签）
# 每步展示不同内容区域

EXTENDS: base_form
META: Entity("TravelChangeOrder"), Domain("Travel"), FormMode("wizard")

[PAGE: change_confirm]
  ATTR: Title("确认改签")
