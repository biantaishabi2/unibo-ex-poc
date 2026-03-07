defmodule UniboExPocWeb.Schema do
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboExPoc.Delivery,
      UniboExPoc.Ecommerce,
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
