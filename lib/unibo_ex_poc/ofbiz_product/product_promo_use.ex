defmodule UniboV4.Ofbiz.Product.ProductPromoUse do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_promo_uses"
    repo UniboV4.Repo
  end

  graphql do
    type :product_product_promo_use

    queries do
      get :get_product_product_promo_use, :read
      list :list_product_product_promo_uses, :read
    end

    mutations do
      create :create_product_product_promo_use, :create
      update :update_product_product_promo_use, :update
      destroy :delete_product_product_promo_use, :destroy
    end

  end

  attributes do
    attribute :order_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :promo_sequence_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string, public?: true
    attribute :total_discount_amount, :decimal, public?: true
    attribute :quantity_left_in_actions, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_promo, UniboV4.Ofbiz.Product.ProductPromo do
      public? true
    end
    belongs_to :product_promo_code, UniboV4.Ofbiz.Product.ProductPromoCode do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
