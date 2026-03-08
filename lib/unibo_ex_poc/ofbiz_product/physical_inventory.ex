defmodule UniboV4.Ofbiz.Product.PhysicalInventory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_physical_inventories"
    repo UniboV4.Repo
  end

  graphql do
    type :product_physical_inventory

    queries do
      get :get_product_physical_inventory, :read
      list :list_product_physical_inventorys, :read
    end

    mutations do
      create :create_product_physical_inventory, :create
      update :update_product_physical_inventory, :update
      destroy :delete_product_physical_inventory, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :physical_inventory_id, :string, public?: true
    attribute :physical_inventory_date, :utc_datetime, public?: true
    attribute :party_id, :string, public?: true
    attribute :general_comments, :string, public?: true
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
