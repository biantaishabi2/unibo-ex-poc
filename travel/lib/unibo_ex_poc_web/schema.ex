defmodule UniboExPocWeb.Schema do
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboExPoc.Travel,
    ]

  query do
  end

  mutation do
  end
end
