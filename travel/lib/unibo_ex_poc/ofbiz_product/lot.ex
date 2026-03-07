defmodule UniboExPoc.Ofbiz.Product.Lot do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_lots"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_lot

    queries do
      get :get_product_lot, :read
      list :list_product_lots, :read
    end

    mutations do
      create :create_product_lot, :create
      update :update_product_lot, :update
      destroy :delete_product_lot, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :lot_id, :string, public?: true
    attribute :creation_date, :utc_datetime, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :expiration_date, :utc_datetime, public?: true
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
