defmodule UniboV4.Sales do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Sales.Customer
    resource UniboV4.Sales.Quote
    resource UniboV4.Sales.QuoteItem
    resource UniboV4.Sales.SalesOrder
    resource UniboV4.Sales.SalesOrderItem
    resource UniboV4.Sales.SalesOrderShipment
    resource UniboV4.Sales.Return
    resource UniboV4.Sales.ReturnItem
    resource UniboV4.Sales.DeliveryCarrier
    resource UniboV4.Sales.DeliveryPriceRule
    resource UniboV4.Sales.User
    resource UniboV4.Sales.Product
    resource UniboV4.Sales.Tax
    resource UniboV4.Sales.SalesOrderItemTaxRel
  end
end
