defmodule UniboExPoc.Travel.Workflows.RefundToOrderCancelReactor do
  @moduledoc """
  跨实体工作流 Reactor — 自动生成。
  退票单退款完成后，触发原订单执行 approve_cancel；失败时退票单状态仍保持 refunded（退款已完成，订单取消为最终补偿）
  """

  use Ash.Reactor

  input :refund_id

  read_one :read_refund_order, UniboExPoc.Travel.TravelRefundOrder, :read do
    inputs %{id: input(:refund_id)}
    fail_on_not_found? true
  end

  update :refund, UniboExPoc.Travel.TravelRefundOrder, :refund do
    initial result(:read_refund_order)
  end

  read_one :read_target_order, UniboExPoc.Travel.TravelOrder, :read do
    inputs %{id: element(:refund, [:original_order_id])}
    fail_on_not_found? true
    wait_for :refund
  end

  update :approve_cancel, UniboExPoc.Travel.TravelOrder, :approve_cancel do
    initial result(:read_target_order)
    wait_for :refund
  end

  # --- 补偿步骤 ---

  update :undo_reject, UniboExPoc.Travel.TravelRefundOrder, :reject do
    initial result(:refund)
    # 补偿步骤 #1
  end

end
