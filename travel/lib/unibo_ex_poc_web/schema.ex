defmodule UniboExPocWeb.Schema do
  # 本文件由 compile-project 自动生成，请勿只单独复制或替换 schema.ex。
  # GraphQL 宿主必须与 lib/**、config/config.exs、test/support 一起整套同步，否则 ash_domains 与生成域模块可能失配。
  use Absinthe.Schema

  def unibo_runtime_domains do
    [
      UniboExPoc.Accounting,
      UniboExPoc.Delivery,
      UniboExPoc.Ecommerce,
      UniboExPoc.Ofbiz.Accounting,
      UniboExPoc.Ofbiz.Common,
      UniboExPoc.Ofbiz.Order,
      UniboExPoc.Ofbiz.Party,
      UniboExPoc.Ofbiz.Product,
      UniboExPoc.Ofbiz.Shipment,
      UniboExPoc.Payment,
      UniboExPoc.Purchasing,
      UniboExPoc.Sales,
      UniboExPoc.Travel,
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
      UniboExPoc.Accounting,
      UniboExPoc.Delivery,
      UniboExPoc.Ecommerce,
      UniboExPoc.Ofbiz.Accounting,
      UniboExPoc.Ofbiz.Common,
      UniboExPoc.Ofbiz.Order,
      UniboExPoc.Ofbiz.Party,
      UniboExPoc.Ofbiz.Product,
      UniboExPoc.Ofbiz.Shipment,
      UniboExPoc.Payment,
      UniboExPoc.Purchasing,
      UniboExPoc.Sales,
      UniboExPoc.Travel,
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
