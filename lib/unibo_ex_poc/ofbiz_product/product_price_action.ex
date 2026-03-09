defmodule UniboExPoc.Ofbiz.Product.ProductPriceAction do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_price_actions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_price_action

    queries do
      get :get_product_product_price_action, :read
      list :list_product_product_price_actions, :read
    end

    mutations do
      create :create_product_product_price_action, :create
      update :update_product_product_price_action, :update
      destroy :delete_product_product_price_action, :destroy
    end

  end

  attributes do
    attribute :product_price_action_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :amount, :decimal, public?: true
    attribute :rate_code, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_price_action_type, UniboExPoc.Ofbiz.Product.ProductPriceActionType do
      public? true
    end
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
