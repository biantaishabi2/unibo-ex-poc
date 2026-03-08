defmodule UniboExPoc.Ofbiz.Product.ProductPromoAction do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_promo_actions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_promo_action

    queries do
      get :get_product_product_promo_action, :read
      list :list_product_product_promo_actions, :read
    end

    mutations do
      create :create_product_product_promo_action, :create
      update :update_product_product_promo_action, :update
      destroy :delete_product_product_promo_action, :destroy
    end

  end

  attributes do
    attribute :product_promo_rule_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_promo_action_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_promo_action_enum_id, :string, public?: true
    attribute :custom_method_id, :string, public?: true
    attribute :order_adjustment_type_id, :string, public?: true
    attribute :service_name, :string, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :amount, :decimal, public?: true
    attribute :product_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :use_cart_quantity, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_promo, UniboExPoc.Ofbiz.Product.ProductPromo do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
