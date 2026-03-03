defmodule UniboV4Web.Schema.Purchasing do
  @moduledoc "采购供应链子域 — Purchasing, Inventory"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Purchasing,
      UniboV4.Inventory
    ]

  query do
  end

  mutation do
  end
end
