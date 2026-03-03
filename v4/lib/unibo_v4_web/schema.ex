defmodule UniboV4Web.Schema do
  use Absinthe.Schema

  # GraphQL 域由子域 Schema 分别处理，主 Schema 仅提供最小定义

  query do
    field :health, :string do
      resolve(fn _, _, _ -> {:ok, "ok"} end)
    end
  end
end
