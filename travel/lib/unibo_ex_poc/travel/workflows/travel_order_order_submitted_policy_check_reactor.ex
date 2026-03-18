defmodule UniboExPoc.Travel.Workflows.OrderSubmittedPolicyCheckReactor do
  @moduledoc """
  跨实体工作流 Reactor — 自动生成。
  订单提交后，跨实体创建 TravelPolicyCheck 记录差标校验结果
  """

  use Ash.Reactor

  input :submit_order_id

  read_one :read_order, UniboExPoc.Travel.TravelOrder, :read do
    inputs %{id: input(:submit_order_id)}
    fail_on_not_found? true
  end

  update :submit_order, UniboExPoc.Travel.TravelOrder, :submit_order do
    initial result(:read_order)
  end

  create :create, UniboExPoc.Travel.TravelPolicyCheck, :create do
    inputs %{order_id: element(:submit_order, [:id])}
  end

end
