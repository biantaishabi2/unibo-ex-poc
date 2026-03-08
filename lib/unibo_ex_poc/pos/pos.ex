defmodule UniboV4.POS do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.POS.PosSession
    resource UniboV4.POS.PosSession.Version
    resource UniboV4.POS.PosOrder
    resource UniboV4.POS.PosOrder.Version
    resource UniboV4.POS.PosOrderLine
    resource UniboV4.POS.PosOrderLine.Version
    resource UniboV4.POS.PosPayment
    resource UniboV4.POS.Currency
    resource UniboV4.POS.FiscalPosition
    resource UniboV4.POS.Product
    resource UniboV4.POS.PosPaymentMethod
    resource UniboV4.POS.PosConfig
    resource UniboV4.POS.PosConfig.Version
    resource UniboV4.POS.PosConfigFloor
    resource UniboV4.POS.PosConfigFloor.Version
    resource UniboV4.POS.RestaurantFloor
    resource UniboV4.POS.RestaurantFloor.Version
    resource UniboV4.POS.RestaurantTable
    resource UniboV4.POS.RestaurantTable.Version
    resource UniboV4.POS.Party
  end
end
