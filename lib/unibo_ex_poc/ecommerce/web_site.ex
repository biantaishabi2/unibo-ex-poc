defmodule UniboV4.Ecommerce.WebSite do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域站点占位实体"
  end

  postgres do
    table "ecommerce_web_sites"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_web_site

    queries do
      get :get_ecommerce_web_site, :read
      list :list_ecommerce_web_sites, :read
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
