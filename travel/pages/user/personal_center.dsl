# 个人中心页
# 展示用户头像/信息、快捷入口、出差统计、设置入口

EXTENDS: base_object_page
META: Entity("TravelOrder"), Domain("Travel"), Display("mobile_profile")

[PAGE: personal_center]
  ATTR: Title("个人中心")
