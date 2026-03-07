defmodule UniboExPoc.Ofbiz.Product.ProductStoreKeywordOvrd do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_store_keyword_ovrds"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_store_keyword_ovrd

    queries do
      get :get_product_product_store_keyword_ovrd, :read
      list :list_product_product_store_keyword_ovrds, :read
    end

    mutations do
      create :create_product_product_store_keyword_ovrd, :create
      update :update_product_product_store_keyword_ovrd, :update
      destroy :delete_product_product_store_keyword_ovrd, :destroy
    end

  end

  attributes do
    attribute :keyword, :string do
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
    attribute :target, :string, public?: true
    attribute :target_type_enum_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store, UniboExPoc.Ofbiz.Product.ProductStore do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
