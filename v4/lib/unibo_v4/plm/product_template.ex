defmodule UniboV4.PLM.ProductTemplate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
