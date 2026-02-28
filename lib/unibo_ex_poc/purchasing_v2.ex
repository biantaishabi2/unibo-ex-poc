defmodule UniboExPoc.PurchasingV2 do
  @moduledoc """
  V2 采购领域：验证应用层能力（Actor/Policy/Notifier/定制逻辑）。
  """
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    # V2 需要开启授权，验证 Policy 能力
    authorize?(true)
  end

  resources do
    resource(UniboExPoc.PurchasingV2.Party)
    resource(UniboExPoc.PurchasingV2.Product)
    resource(UniboExPoc.PurchasingV2.Order)
    resource(UniboExPoc.PurchasingV2.OrderItem)
  end
end
