defmodule UniboExPoc.TravelExt.Workflows.RefundToOrderCancelReactor do
  @moduledoc """
  跨实体工作流 Reactor — 自动生成。
  退票单退款完成后，触发原订单执行 approve_cancel；失败时退票单状态仍保持 refunded（退款已完成，订单取消为最终补偿）
  """

  use Ash.Reactor

  input :refund_id

  read_one :load_refund, UniboExPoc.TravelExt.TravelRefundOrder, :read do
    inputs %{id: input(:refund_id)}
  end

  update :refund, UniboExPoc.TravelExt.TravelRefundOrder, :refund do
    initial result(:load_refund)
    inputs %{id: input(:refund_id)}
  end

  update :approve_cancel, UniboExPoc.TravelExt.TravelOrder, :approve_cancel do
    initial result(:refund)
    inputs %{id: result(:refund, [:original_order_id])}
    wait_for :refund
  end

  # --- 补偿步骤 ---

  update :undo_reject, UniboExPoc.TravelExt.TravelRefundOrder, :reject do
    initial result(:refund)
    # 补偿步骤 #1
  end

end
