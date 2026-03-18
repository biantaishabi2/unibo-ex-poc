defmodule UniboExPoc.Travel.Workflows.PaymentConfirmedToFulfillmentReactor do
  @moduledoc """
  跨实体工作流 Reactor — 自动生成。
  订单支付确认后，跨实体创建 TravelFulfillment 并发起供应商预订确认；履约失败时由 TravelFulfillment 自行处理 fail_fulfillment
  """

  use Ash.Reactor

  input :mark_payment_succeeded_id

  read_one :read_order, UniboExPoc.Travel.TravelOrder, :read do
    inputs %{id: input(:mark_payment_succeeded_id)}
    fail_on_not_found? true
  end

  update :mark_payment_succeeded, UniboExPoc.Travel.TravelOrder, :mark_payment_succeeded do
    initial result(:read_order)
  end

  create :create_fulfillment, UniboExPoc.Travel.TravelFulfillment, :create_fulfillment do
    inputs %{
      fulfillment_type: value("reserve_room"),
      tenant_id: element(:mark_payment_succeeded, [:tenant_id]),
      travel_order_id: element(:mark_payment_succeeded, [:id])
    }
  end

  # --- 补偿步骤 ---

  update :undo_mark_order_failed, UniboExPoc.Travel.TravelOrder, :mark_order_failed do
    initial result(:mark_payment_succeeded)
    # 补偿步骤 #1
  end

end
