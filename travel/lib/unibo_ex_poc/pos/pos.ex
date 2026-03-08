defmodule UniboExPoc.POS do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.POS.PosSession
    resource UniboExPoc.POS.PosSession.Version
    resource UniboExPoc.POS.PosOrder
    resource UniboExPoc.POS.PosOrder.Version
    resource UniboExPoc.POS.PosOrderLine
    resource UniboExPoc.POS.PosOrderLine.Version
    resource UniboExPoc.POS.PosPayment
    resource UniboExPoc.POS.Currency
    resource UniboExPoc.POS.FiscalPosition
    resource UniboExPoc.POS.Product
    resource UniboExPoc.POS.PosPaymentMethod
    resource UniboExPoc.POS.PosConfig
    resource UniboExPoc.POS.PosConfig.Version
    resource UniboExPoc.POS.PosConfigFloor
    resource UniboExPoc.POS.PosConfigFloor.Version
    resource UniboExPoc.POS.RestaurantFloor
    resource UniboExPoc.POS.RestaurantFloor.Version
    resource UniboExPoc.POS.RestaurantTable
    resource UniboExPoc.POS.RestaurantTable.Version
    resource UniboExPoc.POS.Party
  end
end
