defmodule UniboV4.Ofbiz.Product.ProdCatalogInvFacility do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_prod_catalog_inv_facilities"
    repo UniboV4.Repo
  end

  graphql do
    type :product_prod_catalog_inv_facility

    queries do
      get :get_product_prod_catalog_inv_facility, :read
      list :list_product_prod_catalog_inv_facilitys, :read
    end

    mutations do
      create :create_product_prod_catalog_inv_facility, :create
      update :update_product_prod_catalog_inv_facility, :update
      destroy :delete_product_prod_catalog_inv_facility, :destroy
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
    belongs_to :prod_catalog, UniboV4.Ofbiz.Product.ProdCatalog do
      public? true
    end
    belongs_to :facility, UniboV4.Ofbiz.Product.Facility do
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
