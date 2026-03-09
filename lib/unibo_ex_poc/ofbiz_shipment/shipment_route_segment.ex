defmodule UniboExPoc.Ofbiz.Shipment.ShipmentRouteSegment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_route_segments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_route_segment

    queries do
      get :get_shipment_shipment_route_segment, :read
      list :list_shipment_shipment_route_segments, :read
    end

    mutations do
      create :create_shipment_shipment_route_segment, :create
      update :update_shipment_shipment_route_segment, :update
      destroy :delete_shipment_shipment_route_segment, :destroy
    end

  end

  attributes do
    attribute :shipment_route_segment_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :carrier_delivery_zone, :string, public?: true
    attribute :carrier_restriction_codes, :string, public?: true
    attribute :carrier_restriction_desc, :string, public?: true
    attribute :billing_weight, :decimal, public?: true
    attribute :actual_transport_cost, :decimal, public?: true
    attribute :actual_service_cost, :decimal, public?: true
    attribute :actual_other_cost, :decimal, public?: true
    attribute :actual_cost, :decimal, public?: true
    attribute :actual_start_date, :utc_datetime, public?: true
    attribute :actual_arrival_date, :utc_datetime, public?: true
    attribute :estimated_start_date, :utc_datetime, public?: true
    attribute :estimated_arrival_date, :utc_datetime, public?: true
    attribute :tracking_id_number, :string, public?: true
    attribute :tracking_digest, :string, public?: true
    attribute :updated_by_user_login_id, :string, public?: true
    attribute :last_updated_date, :utc_datetime, public?: true
    attribute :home_delivery_type, :string, public?: true
    attribute :home_delivery_date, :utc_datetime, public?: true
    attribute :third_party_account_number, :string, public?: true
    attribute :third_party_postal_code, :string, public?: true
    attribute :third_party_country_geo_code, :string, public?: true
    attribute :ups_high_value_report, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
      public? true
      attribute_type :string
    end
    belongs_to :delivery, UniboExPoc.Ofbiz.Shipment.Delivery do
      public? true
      attribute_type :string
    end
    belongs_to :carrier_party, UniboExPoc.Ofbiz.Shipment.Party do
      public? true
      attribute_type :string
    end
    belongs_to :carrier_person, UniboExPoc.Ofbiz.Shipment.Person do
      public? true
      source_attribute :carrier_party_id
      define_attribute? false
      attribute_type :string
    end
    belongs_to :carrier_party_group, UniboExPoc.Ofbiz.Shipment.PartyGroup do
      public? true
      source_attribute :carrier_party_id
      define_attribute? false
      attribute_type :string
    end
    belongs_to :shipment_method_type, UniboExPoc.Ofbiz.Shipment.ShipmentMethodType do
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
    belongs_to :origin_contact_mech, UniboExPoc.Ofbiz.Shipment.ContactMech do
      public? true
      attribute_type :string
    end
    belongs_to :dest_contact_mech, UniboExPoc.Ofbiz.Shipment.ContactMech do
      public? true
      attribute_type :string
    end
    belongs_to :origin_postal_address, UniboExPoc.Ofbiz.Shipment.PostalAddress do
      public? true
      source_attribute :origin_contact_mech_id
      define_attribute? false
      attribute_type :string
    end
    belongs_to :origin_telecom_number, UniboExPoc.Ofbiz.Shipment.TelecomNumber do
      public? true
      attribute_type :string
    end
    belongs_to :dest_postal_address, UniboExPoc.Ofbiz.Shipment.PostalAddress do
      public? true
      source_attribute :dest_contact_mech_id
      define_attribute? false
      attribute_type :string
    end
    belongs_to :dest_telecom_number, UniboExPoc.Ofbiz.Shipment.TelecomNumber do
      public? true
      attribute_type :string
    end
    belongs_to :carrier_service_status_item, UniboExPoc.Ofbiz.Shipment.StatusItem do
      public? true
      source_attribute :carrier_service_status_id
      attribute_type :string
    end
    belongs_to :currency_uom, UniboExPoc.Ofbiz.Shipment.Uom do
      public? true
      attribute_type :string
    end
    belongs_to :billing_weight_uom, UniboExPoc.Ofbiz.Shipment.Uom do
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
