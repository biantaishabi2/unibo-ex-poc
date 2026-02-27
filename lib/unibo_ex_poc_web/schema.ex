defmodule UniboExPocWeb.Schema do
  @moduledoc """
  GraphQL Schema 入口。

  通过 AshGraphql 直接从 Domain 导出查询与变更，保持无 BFF 路径。
  """
  use Absinthe.Schema

  use AshGraphql, domains: [UniboExPoc.Purchasing]

  import_types Absinthe.Plug.Types

  query do
    # 占位查询，保证 schema 根 query 类型存在
    field :health, :string do
      resolve(fn _, _, _ -> {:ok, "ok"} end)
    end
  end

  mutation do
    # 具体 mutation 由 AshGraphql 自动注入
  end
end
