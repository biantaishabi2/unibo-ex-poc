defmodule UniboExPoc.Ofbiz.Product.ProductPriceCond do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_price_conds"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_price_cond

    queries do
      get :get_product_product_price_cond, :read
      list :list_product_product_price_conds, :read
    end

    mutations do
      create :create_product_product_price_cond, :create
      update :update_product_product_price_cond, :update
      destroy :delete_product_product_price_cond, :destroy
    end

  end

  attributes do
    attribute :product_price_cond_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :input_param_enum_id, :string, public?: true
    attribute :operator_enum_id, :string, public?: true
    attribute :cond_value, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_price_rule, UniboExPoc.Ofbiz.Product.ProductPriceRule do
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
