defmodule UniboExPoc.Ofbiz.Product.ProductPromoRule do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_promo_rules"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_promo_rule

    queries do
      get :get_product_product_promo_rule, :read
      list :list_product_product_promo_rules, :read
    end

    mutations do
      create :create_product_product_promo_rule, :create
      update :update_product_product_promo_rule, :update
      destroy :delete_product_product_promo_rule, :destroy
    end

  end

  attributes do
    attribute :product_promo_rule_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :rule_name, :string, public?: true
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
