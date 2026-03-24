defmodule UniboExPoc.TravelExt do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.TravelExt.TravelChangeOrder
    resource UniboExPoc.TravelExt.TravelChangeOrder.Version
    resource UniboExPoc.TravelExt.TravelRefundOrder
    resource UniboExPoc.TravelExt.TravelRefundOrder.Version
    resource UniboExPoc.TravelExt.TravelPolicy
    resource UniboExPoc.TravelExt.TravelPolicy.Version
    resource UniboExPoc.TravelExt.TravelPolicyCheck
  end
end
