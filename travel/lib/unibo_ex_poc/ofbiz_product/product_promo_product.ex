defmodule UniboExPoc.Ofbiz.Product.ProductPromoProduct do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_promo_products"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_promo_product

    queries do
      get :get_product_product_promo_product, :read
      list :list_product_product_promo_products, :read
    end

    mutations do
      create :create_product_product_promo_product, :create
      update :update_product_product_promo_product, :update
      destroy :delete_product_product_promo_product, :destroy
    end

  end

  attributes do
    attribute :product_promo_rule_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :product_promo_action_seq_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :product_promo_cond_seq_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :product_promo_appl_enum_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_promo, UniboExPoc.Ofbiz.Product.ProductPromo do
      public? true
    end
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
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
