defmodule UniboExPoc.Ofbiz.Product.ProductPaymentMethodType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_payment_method_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_payment_method_type

    queries do
      get :get_product_product_payment_method_type, :read
      list :list_product_product_payment_method_types, :read
    end

    mutations do
      create :create_product_product_payment_method_type, :create
      update :update_product_product_payment_method_type, :update
      destroy :delete_product_product_payment_method_type, :destroy
    end

  end

  attributes do
    attribute :payment_method_type_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :product_price_purpose, UniboExPoc.Ofbiz.Product.ProductPricePurpose do
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
