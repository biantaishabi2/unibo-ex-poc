defmodule UniboExPoc.Ofbiz.Product.ProdPromoCodeContactMech do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_prod_promo_code_contact_meches"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_prod_promo_code_contact_mech

    queries do
      get :get_product_prod_promo_code_contact_mech, :read
      list :list_product_prod_promo_code_contact_mechs, :read
    end

    mutations do
      create :create_product_prod_promo_code_contact_mech, :create
      update :update_product_prod_promo_code_contact_mech, :update
      destroy :delete_product_prod_promo_code_contact_mech, :destroy
    end

  end

  attributes do
    attribute :contact_mech_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_promo_code, UniboExPoc.Ofbiz.Product.ProductPromoCode do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
