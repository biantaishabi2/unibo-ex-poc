defmodule UniboV4.Ofbiz.Shipment.ShipmentBoxType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_box_types"
    repo UniboV4.Repo
  end

  graphql do
    type :shipment_shipment_box_type

    queries do
      get :get_shipment_shipment_box_type, :read
      list :list_shipment_shipment_box_types, :read
    end

    mutations do
      create :create_shipment_shipment_box_type, :create
      update :update_shipment_shipment_box_type, :update
      destroy :delete_shipment_shipment_box_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :shipment_box_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :box_length, :decimal, public?: true
    attribute :box_width, :decimal, public?: true
    attribute :box_height, :decimal, public?: true
    attribute :box_weight, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :dimension_uom, UniboV4.Ofbiz.Shipment.Uom do
      public? true
      attribute_type :string
    end
    belongs_to :weight_uom, UniboV4.Ofbiz.Shipment.Uom do
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
