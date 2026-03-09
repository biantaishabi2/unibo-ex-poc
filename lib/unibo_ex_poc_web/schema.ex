defmodule UniboExPocWeb.Schema do
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboExPoc.Delivery,
      UniboExPoc.Ecommerce,
      UniboExPoc.Ofbiz.Accounting,
      UniboExPoc.Ofbiz.Common,
      UniboExPoc.Ofbiz.Content,
      UniboExPoc.Ofbiz.Order,
      UniboExPoc.Ofbiz.Party,
      UniboExPoc.Ofbiz.Product,
      UniboExPoc.Ofbiz.Shipment,
      UniboExPoc.Payment,
      UniboExPoc.Sales,
      UniboExPoc.Travel,
      UniboExPoc.Website,
    ]

  query do
  end

  mutation do
  end
end
