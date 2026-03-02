defmodule UniboV4.Ecommerce.WebSite do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "web_sites"
    repo UniboV4.Repo
  end

  graphql do
    type :web_site

    queries do
      get :get_web_site, :read
      list :list_web_sites, :read
    end

    mutations do
      create :create_web_site, :create
      update :update_web_site, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :site_code, :string, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :domain_name, :string, public?: true
    attribute :is_active, :boolean, default: true, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:site_code, :name, :domain_name, :description]
      validate present(:site_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :domain_name, :is_active, :description]
    end
  end

  identities do
    identity :unique_site_code, [:site_code]
  end

end
