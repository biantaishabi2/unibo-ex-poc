defmodule UniboExPoc.Travel.Workflows.ChangeApprovalToOrderConfirmReactor do
  @moduledoc """
  跨实体工作流 Reactor — 自动生成。
  改签审批完成后，触发原订单执行 confirm_change；失败时回滚改签单为 rejected
  """

  use Ash.Reactor

  input :complete_id

  read_one :read_change_order, UniboExPoc.Travel.TravelChangeOrder, :read do
    inputs %{id: input(:complete_id)}
    fail_on_not_found? true
  end

  update :complete, UniboExPoc.Travel.TravelChangeOrder, :complete do
    initial result(:read_change_order)
  end

  read_one :read_target_order, UniboExPoc.Travel.TravelOrder, :read do
    inputs %{id: element(:complete, [:original_order_id])}
    fail_on_not_found? true
    wait_for :complete
  end

  update :confirm_change, UniboExPoc.Travel.TravelOrder, :confirm_change do
    initial result(:read_target_order)
    wait_for :complete
  end

  # --- 补偿步骤 ---

  update :undo_reject, UniboExPoc.Travel.TravelChangeOrder, :reject do
    initial result(:complete)
    # 补偿步骤 #1
  end

end
