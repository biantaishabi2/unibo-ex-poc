defmodule UniboV4Web.Schema.Sales do
  @moduledoc "销售客户子域 — Sales, CRM, Ecommerce, POS, Subscriptions, Rental"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Sales,
      UniboV4.CRM,
      UniboV4.Ecommerce,
      UniboV4.POS,
      UniboV4.Subscriptions,
      UniboV4.Rental
    ]

  query do
  end

  mutation do
  end
end
