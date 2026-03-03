# Workflow: delivery_trip_flow — 物流行程生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> start
#   create --> destroy
#   start --> arrive
#   arrive --> [*]
#   update --> start
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Delivery.Delivery do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "delivery_deliveries"
    repo UniboV4.Repo
  end

  graphql do
    type :delivery_delivery

    queries do
      get :get_delivery_delivery, :read
      list :list_delivery_deliverys, :read
    end

    mutations do
      create :create_delivery_delivery, :create
      update :update_delivery_delivery, :update
      update :start_delivery_delivery, :start
      update :arrive_delivery_delivery, :arrive
      destroy :delete_delivery_delivery, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :delivery_id, :string, public?: true
    attribute :actual_start_date, :utc_datetime, public?: true
    attribute :actual_arrival_date, :utc_datetime, public?: true
    attribute :estimated_start_date, :utc_datetime, public?: true
    attribute :estimated_arrival_date, :utc_datetime, public?: true
    attribute :start_mileage, :decimal, public?: true
    attribute :end_mileage, :decimal, public?: true
    attribute :fuel_used, :decimal, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :origin_facility, UniboV4.Delivery.Facility do
      public? true
    end
    belongs_to :dest_facility, UniboV4.Delivery.Facility do
      public? true
    end
    belongs_to :fixed_asset, UniboV4.Delivery.FixedAsset do
      public? true
    end
    has_many :route_segments, UniboV4.Delivery.ShipmentRouteSegment do
      public? true
      destination_attribute :delivery_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:delivery_id, :estimated_start_date, :estimated_arrival_date, :start_mileage]
      validate present(:origin_facility_id)
      validate present(:dest_facility_id)
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
      accept [:actual_start_date, :actual_arrival_date, :end_mileage, :fuel_used]
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
    update :start do
      accept [:actual_start_date, :start_mileage]
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
    update :arrive do
      accept [:actual_arrival_date, :end_mileage, :fuel_used]
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
