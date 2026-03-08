defmodule UniboV4.Ofbiz.Product.ProductPromo do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_promos"
    repo UniboV4.Repo
  end

  graphql do
    type :product_product_promo

    queries do
      get :get_product_product_promo, :read
      list :list_product_product_promos, :read
    end

    mutations do
      create :create_product_product_promo, :create
      update :update_product_product_promo, :update
      destroy :delete_product_product_promo, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_promo_id, :string, public?: true
    attribute :promo_name, :string, public?: true
    attribute :promo_text, :string, public?: true
    attribute :user_entered, :boolean, public?: true
    attribute :show_to_customer, :boolean, public?: true
    attribute :require_code, :boolean, public?: true
    attribute :use_limit_per_order, :integer, public?: true
    attribute :use_limit_per_customer, :integer, public?: true
    attribute :use_limit_per_promotion, :integer, public?: true
    attribute :billback_factor, :decimal, public?: true
    attribute :override_org_party_id, :string, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
