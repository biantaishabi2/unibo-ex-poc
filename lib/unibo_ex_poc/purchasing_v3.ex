defmodule UniboExPoc.PurchasingV3 do
  @moduledoc """
  V3 采购领域：验证金额分级审批 + 风险供应商拦截。
  """
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    # V3 沿用应用层授权控制
    authorize?(true)
  end

  resources do
    resource(UniboExPoc.PurchasingV3.Party)
    resource(UniboExPoc.PurchasingV3.Order)
  end
end
