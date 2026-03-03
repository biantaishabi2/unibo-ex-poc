defmodule UniboV4Web.Schema.Marketing do
  @moduledoc "营销传播子域 — Marketing, Communication, LiveChat"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Marketing,
      UniboV4.Communication,
      UniboV4.LiveChat
    ]

  query do
  end

  mutation do
  end
end
