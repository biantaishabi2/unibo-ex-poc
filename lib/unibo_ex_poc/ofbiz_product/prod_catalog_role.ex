defmodule UniboV4.Ofbiz.Product.ProdCatalogRole do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_prod_catalog_roles"
    repo UniboV4.Repo
  end

  graphql do
    type :product_prod_catalog_role

    queries do
      get :get_product_prod_catalog_role, :read
      list :list_product_prod_catalog_roles, :read
    end

    mutations do
      create :create_product_prod_catalog_role, :create
      update :update_product_prod_catalog_role, :update
      destroy :delete_product_prod_catalog_role, :destroy
    end

  end

  attributes do
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :prod_catalog, UniboV4.Ofbiz.Product.ProdCatalog do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
