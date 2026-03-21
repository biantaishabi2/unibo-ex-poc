# 我的审批页（后端驱动）
# 使用 META+BIND 模式，展示待审批/已审批/已拒绝的审批请求列表

EXTENDS: base_worklist
META: Entity("TravelPolicyCheck"), Domain("Travel")

[PAGE: my_approvals]
  ATTR: Title("我的审批")
