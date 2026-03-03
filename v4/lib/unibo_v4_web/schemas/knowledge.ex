defmodule UniboV4Web.Schema.Knowledge do
  @moduledoc "知识内容子域 — Knowledge, Blog, Forum, Documents, Survey, Sign"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Knowledge,
      UniboV4.Blog,
      UniboV4.Forum,
      UniboV4.Documents,
      UniboV4.Survey,
      UniboV4.Sign
    ]

  query do
  end

  mutation do
  end
end
