defmodule UniboV4Web.Schema.HR do
  @moduledoc "人事行政子域 — HR, Lunch"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.HR,
      UniboV4.Lunch
    ]

  query do
  end

  mutation do
  end
end
