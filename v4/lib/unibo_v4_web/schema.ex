defmodule UniboV4Web.Schema do
  use Absinthe.Schema

  # GraphQL 编译已关闭（--graphql false）

  # 生成最小可编译 Schema，避免 query/mutation 空定义报错
  query do
    field :health, :string do
      resolve(fn _, _, _ -> {:ok, "ok"} end)
    end
  end
end
