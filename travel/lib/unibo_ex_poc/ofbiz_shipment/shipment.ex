defmodule UniboExPoc.Ofbiz.Shipment.Shipment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_shipments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment

    queries do
      get :get_shipment_shipment, :read
      list :list_shipment_shipments, :read
    end

    mutations do
      create :create_shipment_shipment, :create
      update :update_shipment_shipment, :update
      destroy :delete_shipment_shipment, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :shipment_id, :string, public?: true
    attribute :primary_ship_group_seq_id, :string, public?: true
    attribute :estimated_ready_date, :utc_datetime, public?: true
    attribute :estimated_ship_date, :utc_datetime, public?: true
    attribute :estimated_arrival_date, :utc_datetime, public?: true
    attribute :latest_cancel_date, :utc_datetime, public?: true
    attribute :estimated_ship_cost, :decimal, public?: true
    attribute :handling_instructions, :string, public?: true
    attribute :additional_shipping_charge, :decimal, public?: true
    attribute :addtl_shipping_charge_desc, :string, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment_type, UniboExPoc.Ofbiz.Shipment.ShipmentType do
      public? true
      attribute_type :string
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.Shipment.StatusItem do
      public? true
      source_attribute :status_id
      attribute_type :string
    end
    belongs_to :estimated_ship_work_effort, UniboExPoc.Ofbiz.Shipment.WorkEffort do
      public? true
      source_attribute :estimated_ship_work_eff_id
      attribute_type :string
    end
    belongs_to :estimated_arrival_work_effort, UniboExPoc.Ofbiz.Shipment.WorkEffort do
      public? true
      source_attribute :estimated_arrival_work_eff_id
      attribute_type :string
    end
    belongs_to :currency_uom, UniboExPoc.Ofbiz.Shipment.Uom do
      public? true
      attribute_type :string
    end
    belongs_to :origin_facility, UniboExPoc.Ofbiz.Shipment.Facility do
      public? true
      attribute_type :string
    end
    belongs_to :destination_facility, UniboExPoc.Ofbiz.Shipment.Facility do
      public? true
      attribute_type :string
    end
    belongs_to :origin_contact_mech, UniboExPoc.Ofbiz.Shipment.ContactMech do
      public? true
      attribute_type :string
    end
    belongs_to :dest_contact_mech, UniboExPoc.Ofbiz.Shipment.ContactMech do
      public? true
      source_attribute :destination_contact_mech_id
      attribute_type :string
    end
    belongs_to :origin_telecom_number, UniboExPoc.Ofbiz.Shipment.TelecomNumber do
      public? true
      attribute_type :string
    end
    belongs_to :destination_telecom_number, UniboExPoc.Ofbiz.Shipment.TelecomNumber do
      public? true
      attribute_type :string
    end
    belongs_to :primary_order_header, UniboExPoc.Ofbiz.Shipment.OrderHeader do
      public? true
      source_attribute :primary_order_id
      attribute_type :string
    end
    belongs_to :primary_return_header, UniboExPoc.Ofbiz.Shipment.ReturnHeader do
      public? true
      source_attribute :primary_return_id
      attribute_type :string
    end
    belongs_to :picklist_bin, UniboExPoc.Ofbiz.Shipment.PicklistBin do
      public? true
      attribute_type :string
    end
    belongs_to :to_party, UniboExPoc.Ofbiz.Shipment.Party do
      public? true
      source_attribute :party_id_to
      attribute_type :string
    end
    belongs_to :from_party, UniboExPoc.Ofbiz.Shipment.Party do
      public? true
      source_attribute :party_id_from
      attribute_type :string
    end
    has_many :shipment_manifest_view, UniboExPoc.Ofbiz.Shipment.ShipmentItem do
      public? true
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
    archive_related [:shipment_manifest_view]
  end

end
