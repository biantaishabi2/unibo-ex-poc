defmodule UniboExPoc.Ofbiz.Product.ProductStoreCatalog do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_store_catalogs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_catalog

    queries do
      get :get_product_product_store_catalog, :read
      list :list_product_product_store_catalogs, :read
    end

    mutations do
      create :create_product_product_store_catalog, :create
      update :update_product_product_store_catalog, :update
      destroy :delete_product_product_store_catalog, :destroy
    end

  end

  attributes do
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
    belongs_to :product_store, UniboExPoc.Ofbiz.Product.ProductStore do
      public? true
    end
    belongs_to :prod_catalog, UniboExPoc.Ofbiz.Product.ProdCatalog do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
