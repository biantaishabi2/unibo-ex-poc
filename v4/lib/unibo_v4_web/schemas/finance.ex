defmodule UniboV4Web.Schema.Finance do
  @moduledoc "财务子域 — Accounting, Expenses, Currency, Uom"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Accounting,
      UniboV4.Expenses,
      UniboV4.Currency,
      UniboV4.Uom
    ]

  query do
  end

  mutation do
  end
end
