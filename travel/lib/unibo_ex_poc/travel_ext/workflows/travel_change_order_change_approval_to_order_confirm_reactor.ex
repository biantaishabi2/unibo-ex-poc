defmodule UniboExPoc.TravelExt.Workflows.ChangeApprovalToOrderConfirmReactor do
  @moduledoc """
  跨实体工作流 Reactor — 自动生成。
  改签审批完成后，触发原订单执行 confirm_change；失败时回滚改签单为 rejected
  """

  use Ash.Reactor

  input :complete_id

  read_one :load_complete, UniboExPoc.TravelExt.TravelChangeOrder, :read do
    inputs %{id: input(:complete_id)}
  end

  update :complete, UniboExPoc.TravelExt.TravelChangeOrder, :complete do
    initial result(:load_complete)
    inputs %{id: input(:complete_id)}
  end

  update :confirm_change, UniboExPoc.TravelExt.TravelOrder, :confirm_change do
    initial result(:complete)
    inputs %{id: result(:complete, [:original_order_id])}
    wait_for :complete
  end

  # --- 补偿步骤 ---

  update :undo_reject, UniboExPoc.TravelExt.TravelChangeOrder, :reject do
    initial result(:complete)
    # 补偿步骤 #1
  end

end
