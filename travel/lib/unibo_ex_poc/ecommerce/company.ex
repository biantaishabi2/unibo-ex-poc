defmodule UniboExPoc.Ecommerce.Company do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "公司占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "ecommerce_companies"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ecommerce_company

    queries do
      get :get_ecommerce_company, :read
      list :list_ecommerce_companys, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
