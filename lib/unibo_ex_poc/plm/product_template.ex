defmodule UniboV4.PLM.ProductTemplate do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "产品模板占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "plm_product_templates"
    repo UniboV4.Repo
  end

  graphql do
    type :plm_product_template

    queries do
      get :get_plm_product_template, :read
      list :list_plm_product_templates, :read
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
