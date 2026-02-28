defmodule UniboV4.Ecommerce.Catalog do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "catalogs"
    repo UniboV4.Repo
  end

  graphql do
    type :catalog

    queries do
      get :get_catalog, :read
      list :list_catalogs, :read
    end

    mutations do
      create :create_catalog, :create
      update :update_catalog, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :catalog_code, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :description, :string
    attribute :is_active, :boolean, default: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:catalog_code, :name, :description]
      validate present(:catalog_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active]
    end
  end

  identities do
    identity :unique_catalog_code, [:catalog_code]
  end

end
