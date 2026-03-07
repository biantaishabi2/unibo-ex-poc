defmodule UniboExPoc.Ofbiz.Product.ProductPriceChange do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_price_changes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_price_change

    queries do
      get :get_product_product_price_change, :read
      list :list_product_product_price_changes, :read
    end

    mutations do
      create :create_product_product_price_change, :create
      update :update_product_product_price_change, :update
      destroy :delete_product_product_price_change, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_price_change_id, :string, public?: true
    attribute :product_id, :string, public?: true
    attribute :product_price_type_id, :string, public?: true
    attribute :product_price_purpose_id, :string, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :product_store_group_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :price, :decimal, public?: true
    attribute :old_price, :decimal, public?: true
    attribute :changed_date, :utc_datetime, public?: true
    attribute :changed_by_user_login, :string, public?: true
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
