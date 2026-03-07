defmodule UniboExPoc.Sales do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Sales.Customer
    resource UniboExPoc.Sales.Customer.Version
    resource UniboExPoc.Sales.Quote
    resource UniboExPoc.Sales.Quote.Version
    resource UniboExPoc.Sales.QuoteItem
    resource UniboExPoc.Sales.QuoteItem.Version
    resource UniboExPoc.Sales.SalesOrder
    resource UniboExPoc.Sales.SalesOrder.Version
    resource UniboExPoc.Sales.SalesOrderItem
    resource UniboExPoc.Sales.SalesOrderItem.Version
    resource UniboExPoc.Sales.SalesOrderShipment
    resource UniboExPoc.Sales.SalesOrderShipment.Version
    resource UniboExPoc.Sales.Return
    resource UniboExPoc.Sales.Return.Version
    resource UniboExPoc.Sales.ReturnItem
    resource UniboExPoc.Sales.ReturnItem.Version
    resource UniboExPoc.Sales.DeliveryCarrier
    resource UniboExPoc.Sales.DeliveryCarrier.Version
    resource UniboExPoc.Sales.DeliveryPriceRule
    resource UniboExPoc.Sales.DeliveryPriceRule.Version
    resource UniboExPoc.Sales.User
    resource UniboExPoc.Sales.Product
    resource UniboExPoc.Sales.Tax
    resource UniboExPoc.Sales.SalesOrderItemTaxRel
  end
end
