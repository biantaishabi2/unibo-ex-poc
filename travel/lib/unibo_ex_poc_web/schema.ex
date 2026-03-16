defmodule UniboExPocWeb.Schema do
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboExPoc.Accounting,
      UniboExPoc.Delivery,
      UniboExPoc.Ecommerce,
      UniboExPoc.Payment,
      UniboExPoc.Purchasing,
      UniboExPoc.Sales,
      UniboExPoc.Travel,
    ]

  query do
  end

  mutation do
  end
end
