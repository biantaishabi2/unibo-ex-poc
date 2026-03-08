defmodule UniboV4.Ofbiz.Product.ProductPromoCategory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_promo_categories"
    repo UniboV4.Repo
  end

  graphql do
    type :product_product_promo_category

    queries do
      get :get_product_product_promo_category, :read
      list :list_product_product_promo_categorys, :read
    end

    mutations do
      create :create_product_product_promo_category, :create
      update :update_product_product_promo_category, :update
      destroy :delete_product_product_promo_category, :destroy
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
    attribute :product_promo_cond_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :and_group_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_promo_appl_enum_id, :string, public?: true
    attribute :include_sub_categories, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_promo, UniboV4.Ofbiz.Product.ProductPromo do
      public? true
    end
    belongs_to :product_category, UniboV4.Ofbiz.Product.ProductCategory do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
