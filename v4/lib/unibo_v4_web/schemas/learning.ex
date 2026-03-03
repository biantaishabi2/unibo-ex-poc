defmodule UniboV4Web.Schema.Learning do
  @moduledoc "在线学习子域 — ELearning"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.ELearning
    ]

  query do
  end

  mutation do
  end
end
