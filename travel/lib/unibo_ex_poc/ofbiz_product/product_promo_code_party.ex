defmodule UniboExPoc.Ofbiz.Product.ProductPromoCodeParty do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_promo_code_parties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_promo_code_party

    queries do
      get :get_product_product_promo_code_party, :read
      list :list_product_product_promo_code_partys, :read
    end

    mutations do
      create :create_product_product_promo_code_party, :create
      update :update_product_product_promo_code_party, :update
      destroy :delete_product_product_promo_code_party, :destroy
    end

  end

  attributes do
    attribute :product_promo_code_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_promo_code, UniboExPoc.Ofbiz.Product.ProductPromoCode do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
