defmodule UniboExPoc.Ofbiz.Product.ProductPromoCond do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_promo_conds"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_promo_cond

    queries do
      get :get_product_product_promo_cond, :read
      list :list_product_product_promo_conds, :read
    end

    mutations do
      create :create_product_product_promo_cond, :create
      update :update_product_product_promo_cond, :update
      destroy :delete_product_product_promo_cond, :destroy
    end

  end

  attributes do
    attribute :product_promo_rule_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_promo_cond_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :custom_method_id, :string, public?: true
    attribute :input_param_enum_id, :string, public?: true
    attribute :operator_enum_id, :string, public?: true
    attribute :cond_value, :string, public?: true
    attribute :other_value, :string, public?: true
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
