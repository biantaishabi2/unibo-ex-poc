defmodule UniboV4Web.Schema.Engagement do
  @moduledoc "用户互动子域 — Gamification, Membership"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Gamification,
      UniboV4.Membership
    ]

  query do
  end

  mutation do
  end
end
