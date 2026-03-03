defmodule UniboV4Web.Generated.Schema.Production do
  @moduledoc "自动生成的 production 子域 GraphQL Schema — 由 UniBO 编译器生成，请勿手动编辑"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Maintenance,
      UniboV4.Manufacturing,
      UniboV4.PLM,
      UniboV4.Quality,
      UniboV4.Repair,
    ]

  query do
  end

  mutation do
  end
end
