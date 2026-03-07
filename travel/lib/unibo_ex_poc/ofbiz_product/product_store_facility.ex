defmodule UniboExPoc.Ofbiz.Product.ProductStoreFacility do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_store_facilities"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_facility

    queries do
      get :get_product_product_store_facility, :read
      list :list_product_product_store_facilitys, :read
    end

    mutations do
      create :create_product_product_store_facility, :create
      update :update_product_product_store_facility, :update
      destroy :delete_product_product_store_facility, :destroy
    end

  end

  attributes do
    attribute :product_store_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :facility_id, :uuid do
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
    belongs_to :product_store, UniboExPoc.Ofbiz.Product.ProductStore do
      public? true
      define_attribute? false
    end
    belongs_to :facility, UniboExPoc.Ofbiz.Product.Facility do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
