defmodule UniboExPocWeb.Generated.Schema.TravelExt do
  @moduledoc "自动生成的 travel_ext 子域 GraphQL Schema — 由 UniBO 编译器生成，请勿手动编辑"
  use Absinthe.Schema

  import_types Absinthe.Plug.Types
  import_types UniboExPocWeb.Generated.AshGraphqlTypes

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
      UniboExPoc.TravelExt,
    ]

  query do
    field :graphql_contract, :graphql_contract do
      arg :field, :string
      arg :doc_url, :string
      resolve(fn _, args, _ -> {:ok, UniboExPocWeb.Graphql.RuntimeConfig.graphql_contract(Map.get(args, :doc_url) || Map.get(args, "doc_url") || Map.get(args, :field) || Map.get(args, "field"))} end)
    end
  end

  mutation do
  end
end
