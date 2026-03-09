defmodule UniboExPoc.Ofbiz.Shipment.Delivery do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_deliveries"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_delivery

    queries do
      get :get_shipment_delivery, :read
      list :list_shipment_deliverys, :read
    end

    mutations do
      create :create_shipment_delivery, :create
      update :update_shipment_delivery, :update
      destroy :delete_shipment_delivery, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :delivery_id, :string, public?: true
    attribute :actual_start_date, :utc_datetime, public?: true
    attribute :actual_arrival_date, :utc_datetime, public?: true
    attribute :estimated_start_date, :utc_datetime, public?: true
    attribute :estimated_arrival_date, :utc_datetime, public?: true
    attribute :start_mileage, :decimal, public?: true
    attribute :end_mileage, :decimal, public?: true
    attribute :fuel_used, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fixed_asset, UniboExPoc.Ofbiz.Shipment.FixedAsset do
      public? true
      attribute_type :string
    end
    belongs_to :origin_facility, UniboExPoc.Ofbiz.Shipment.Facility do
      public? true
      attribute_type :string
    end
    belongs_to :dest_facility, UniboExPoc.Ofbiz.Shipment.Facility do
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
