# Workflow: route_segment_flow — 运输路段生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> confirm_shipment
#   create --> update
#   create --> destroy
#   confirm_shipment --> update_tracking
#   confirm_shipment --> record_cost
#   update_tracking --> record_cost
#   record_cost --> [*]
#   update --> confirm_shipment
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Delivery.ShipmentRouteSegment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Delivery.ShipmentRouteSegment.Notifier]

  postgres do
    table "delivery_shipment_route_segments"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_route_segment_id, :string do
      allow_nil? false
      public? true
    end
    attribute :origin_contact_mech_id, :string, public?: true
    attribute :origin_telecom_number_id, :string, public?: true
    attribute :dest_contact_mech_id, :string, public?: true
    attribute :dest_telecom_number_id, :string, public?: true
    attribute :carrier_service_status_id, :string, public?: true
    attribute :carrier_delivery_zone, :string, public?: true
    attribute :carrier_restriction_codes, :string, public?: true
    attribute :carrier_restriction_desc, :string, public?: true
    attribute :billing_weight, :decimal, public?: true
    attribute :billing_weight_uom_id, :string, public?: true
    attribute :actual_transport_cost, :decimal, public?: true
    attribute :actual_service_cost, :decimal, public?: true
    attribute :actual_other_cost, :decimal, public?: true
    attribute :actual_cost, :decimal, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :actual_start_date, :utc_datetime, public?: true
    attribute :actual_arrival_date, :utc_datetime, public?: true
    attribute :estimated_start_date, :utc_datetime, public?: true
    attribute :estimated_arrival_date, :utc_datetime, public?: true
    attribute :tracking_id_number, :string, public?: true
    attribute :tracking_digest, :string, public?: true
    attribute :home_delivery_type, :string, public?: true
    attribute :home_delivery_date, :utc_datetime, public?: true
    attribute :third_party_account_number, :string, public?: true
    attribute :third_party_postal_code, :string, public?: true
    attribute :third_party_country_geo_code, :string, public?: true
    attribute :updated_by_user_login_id, :string, public?: true
    attribute :last_updated_date, :utc_datetime, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :shipment, UniboV4.Delivery.Shipment do
      public? true
    end
    belongs_to :delivery, UniboV4.Delivery.Delivery do
      public? true
    end
    belongs_to :carrier_party, UniboV4.Delivery.Party do
      public? true
    end
    belongs_to :shipment_method_type, UniboV4.Delivery.ShipmentMethodType do
      public? true
    end
    belongs_to :origin_facility, UniboV4.Delivery.Facility do
      public? true
    end
    belongs_to :dest_facility, UniboV4.Delivery.Facility do
      public? true
    end
    has_many :package_route_segs, UniboV4.Delivery.ShipmentPackageRouteSeg do
      public? true
      destination_attribute :shipment_route_segment_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_route_segment_id, :estimated_start_date, :estimated_arrival_date]
      validate present(:shipment_id)
      validate present(:shipment_route_segment_id)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:tracking_id_number, :carrier_service_status_id, :actual_start_date, :actual_arrival_date, :actual_cost, :billing_weight]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :confirm_shipment do
      accept [:carrier_service_status_id, :tracking_id_number]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :update_tracking do
      accept [:tracking_id_number, :tracking_digest]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :record_cost do
      accept [:actual_transport_cost, :actual_service_cost, :actual_other_cost, :actual_cost, :currency_uom_id, :billing_weight, :billing_weight_uom_id]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

end
