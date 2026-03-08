defmodule UniboV4.Ofbiz.Product.InventoryTransfer do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_inventory_transfers"
    repo UniboV4.Repo
  end

  graphql do
    type :product_inventory_transfer

    queries do
      get :get_product_inventory_transfer, :read
      list :list_product_inventory_transfers, :read
    end

    mutations do
      create :create_product_inventory_transfer, :create
      update :update_product_inventory_transfer, :update
      destroy :delete_product_inventory_transfer, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :inventory_transfer_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :location_seq_id, :string, public?: true
    attribute :location_seq_id_to, :string, public?: true
    attribute :item_issuance_id, :string, public?: true
    attribute :send_date, :utc_datetime, public?: true
    attribute :receive_date, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :inventory_item, UniboV4.Ofbiz.Product.InventoryItem do
      public? true
    end
    belongs_to :facility, UniboV4.Ofbiz.Product.Facility do
      public? true
    end
    belongs_to :container, UniboV4.Ofbiz.Product.Container do
      public? true
    end
    belongs_to :to_facility, UniboV4.Ofbiz.Product.Facility do
      public? true
      source_attribute :facility_id_to
    end
    belongs_to :to_container, UniboV4.Ofbiz.Product.Container do
      public? true
      source_attribute :container_id_to
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
