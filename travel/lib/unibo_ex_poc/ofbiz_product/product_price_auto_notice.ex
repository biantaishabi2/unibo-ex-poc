defmodule UniboExPoc.Ofbiz.Product.ProductPriceAutoNotice do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_price_auto_notices"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_price_auto_notice

    queries do
      get :get_product_product_price_auto_notice, :read
      list :list_product_product_price_auto_notices, :read
    end

    mutations do
      create :create_product_product_price_auto_notice, :create
      update :update_product_product_price_auto_notice, :update
      destroy :delete_product_product_price_auto_notice, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_price_notice_id, :string, public?: true
    attribute :facility_id, :string, public?: true
    attribute :run_date, :utc_datetime, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
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
