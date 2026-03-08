defmodule UniboV4.Ofbiz.Shipment.PicklistBin do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_picklist_bins"
    repo UniboV4.Repo
  end

  graphql do
    type :shipment_picklist_bin

    queries do
      get :get_shipment_picklist_bin, :read
      list :list_shipment_picklist_bins, :read
    end

    mutations do
      create :create_shipment_picklist_bin, :create
      update :update_shipment_picklist_bin, :update
      destroy :delete_shipment_picklist_bin, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :picklist_bin_id, :string, public?: true
    attribute :bin_location_number, :integer, public?: true
    attribute :primary_ship_group_seq_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :picklist, UniboV4.Ofbiz.Shipment.Picklist do
      public? true
      attribute_type :string
    end
    belongs_to :primary_order_header, UniboV4.Ofbiz.Shipment.OrderHeader do
      public? true
      source_attribute :primary_order_id
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
