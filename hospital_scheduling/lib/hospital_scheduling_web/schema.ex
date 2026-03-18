defmodule HospitalSchedulingWeb.Schema do
  # 本文件由 compile-project 自动生成，请勿只单独复制或替换 schema.ex。
  # GraphQL 宿主必须与 lib/**、config/config.exs、test/support 一起整套同步，否则 ash_domains 与生成域模块可能失配。
  use Absinthe.Schema

  def unibo_runtime_domains do
    [
      HospitalScheduling.Scheduling,
    ]
  end

  object :graphql_contract do
    field :field, :string
    field :summary, :string
    field :doc_url, :string
    field :required_headers, list_of(:string)
    field :conditional_requirements, list_of(:string)
    field :body, :string
  end

  use AshGraphql,
    domains: [
      HospitalScheduling.Scheduling,
    ]

  query do
    field :graphql_contract, :graphql_contract do
      arg :field, :string
      arg :doc_url, :string
      resolve(fn _, args, _ -> {:ok, HospitalSchedulingWeb.Graphql.RuntimeConfig.graphql_contract(Map.get(args, :doc_url) || Map.get(args, "doc_url") || Map.get(args, :field) || Map.get(args, "field"))} end)
    end
  end

  mutation do
  end
end
