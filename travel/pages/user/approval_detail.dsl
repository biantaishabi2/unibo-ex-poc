# 审批操作详情页
# 展示申请人信息、申请详情（类型相关）、差标检查、审批链时间轴，支持通过/拒绝操作

EXTENDS: base_object_page
META: Entity("TravelPolicyCheck"), Domain("Travel")

[PAGE: approval_detail]
  ATTR: Title("审批详情")
