defmodule UniboExPoc.Ecommerce.WebSite do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域站点占位实体"
  end

  postgres do
    table "ecommerce_web_sites"
    repo UniboExPoc.Repo
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
