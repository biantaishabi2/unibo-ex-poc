defmodule UniboExPoc.Ofbiz.Product.ProductGlAccount do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_gl_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_gl_account

    queries do
      get :get_product_product_gl_account, :read
      list :list_product_product_gl_accounts, :read
    end

    mutations do
      create :create_product_product_gl_account, :create
      update :update_product_product_gl_account, :update
      destroy :delete_product_product_gl_account, :destroy
    end

  end

  attributes do
    attribute :product_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :organization_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :gl_account_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :gl_account_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
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
