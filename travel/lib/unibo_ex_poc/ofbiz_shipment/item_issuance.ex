defmodule UniboExPoc.Ofbiz.Shipment.ItemIssuance do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_item_issuances"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_item_issuance

    queries do
      get :get_shipment_item_issuance, :read
      list :list_shipment_item_issuances, :read
    end

    mutations do
      create :create_shipment_item_issuance, :create
      update :update_shipment_item_issuance, :update
      destroy :delete_shipment_item_issuance, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :item_issuance_id, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :ship_group_seq_id, :string, public?: true
    attribute :shipment_item_seq_id, :string, public?: true
    attribute :fixed_asset_id, :string, public?: true
    attribute :maint_hist_seq_id, :string, public?: true
    attribute :issued_date_time, :utc_datetime, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :cancel_quantity, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :inventory_item, UniboExPoc.Ofbiz.Shipment.InventoryItem do
      public? true
      attribute_type :string
    end
    belongs_to :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
      public? true
      attribute_type :string
    end
    belongs_to :order_header, UniboExPoc.Ofbiz.Shipment.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
    belongs_to :issued_by_user_login, UniboExPoc.Ofbiz.Shipment.UserLogin do
      public? true
      attribute_type :string
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
