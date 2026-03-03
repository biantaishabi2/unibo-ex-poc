defmodule UniboV4Web.Schema.Production do
  @moduledoc "生产质量子域 — Manufacturing, Maintenance, PLM, Quality"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Manufacturing,
      UniboV4.Maintenance,
      UniboV4.PLM,
      UniboV4.Quality
    ]

  query do
  end

  mutation do
  end
end
