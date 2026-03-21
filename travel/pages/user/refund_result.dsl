# 退票结果页
# 根据退票状态（成功/处理中/被拒绝）显示不同内容

EXTENDS: base_object_page
META: Entity("TravelRefundOrder"), Domain("Travel")

[PAGE: refund_result]
  ATTR: Title("退票结果")
