defmodule UniboV4Web.Schema.Project do
  @moduledoc "项目协作子域 — Project, Helpdesk"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Project,
      UniboV4.Helpdesk
    ]

  query do
  end

  mutation do
  end
end
