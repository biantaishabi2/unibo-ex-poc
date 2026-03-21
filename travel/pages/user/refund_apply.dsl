# 退票申请页
# 表单页：展示原订单信息 + 退票原因选择 + 退款金额预估

EXTENDS: base_form
META: Entity("TravelRefundOrder"), Domain("Travel")

[PAGE: refund_apply]
  ATTR: Title("退票申请")
