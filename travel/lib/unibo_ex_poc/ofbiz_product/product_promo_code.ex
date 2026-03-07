defmodule UniboExPoc.Ofbiz.Product.ProductPromoCode do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_promo_codes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_promo_code

    queries do
      get :get_product_product_promo_code, :read
      list :list_product_product_promo_codes, :read
    end

    mutations do
      create :create_product_product_promo_code, :create
      update :update_product_product_promo_code, :update
      destroy :delete_product_product_promo_code, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_promo_code_id, :string, public?: true
    attribute :user_entered, :boolean, public?: true
    attribute :require_email_or_party, :boolean, public?: true
    attribute :use_limit_per_code, :integer, public?: true
    attribute :use_limit_per_customer, :integer, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
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
