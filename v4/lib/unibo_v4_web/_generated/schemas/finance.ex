defmodule UniboV4Web.Generated.Schema.Finance do
  @moduledoc "自动生成的 finance 子域 GraphQL Schema — 由 UniBO 编译器生成，请勿手动编辑"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Accounting,
      UniboV4.Analytic,
      UniboV4.Currency,
      UniboV4.Expenses,
      UniboV4.Payment,
    ]

  query do
  end

  mutation do
  end
end
