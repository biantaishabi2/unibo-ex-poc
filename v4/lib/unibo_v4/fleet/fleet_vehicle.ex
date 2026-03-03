# Workflow: fleet_vehicle_lifecycle — 车队车辆生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> decommission
#   update --> decommission
#   decommission --> [*]
# ```
defmodule UniboV4.Fleet.FleetVehicle do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Fleet.FleetVehicle.Notifier]

  postgres do
    table "fleet_vehicles"
    repo UniboV4.Repo
  end

  graphql do
    type :fleet_fleet_vehicle

    queries do
      get :get_fleet_fleet_vehicle, :read
      list :list_fleet_fleet_vehicles, :read
    end

    mutations do
      create :create_fleet_fleet_vehicle, :create
      update :update_fleet_fleet_vehicle, :update
      update :decommission_fleet_fleet_vehicle, :decommission
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :vin, :string, public?: true
    attribute :purchase_date, :date, public?: true
    attribute :last_service_date, :utc_datetime, public?: true
    attribute :next_service_date, :utc_datetime, public?: true
    attribute :decommission_date, :date, public?: true
    attribute :acquisition_cost, :decimal, public?: true
    attribute :garage_id, :string, public?: true
    attribute :license_plate, :string do
      allow_nil? false
      public? true
    end
    attribute :brand, :string, public?: true
    attribute :model_name, :string, public?: true
    attribute :model_year, :integer, public?: true
    attribute :odometer, :decimal do
      default 0
      public? true
    end
    attribute :fuel_type, :atom do
      constraints one_of: [:gasoline, :diesel, :electric, :hybrid, :cng]
      public? true
    end
    attribute :color, :string, public?: true
    attribute :seats, :integer, public?: true
    attribute :status, :atom do
      constraints one_of: [:available, :in_use, :maintenance, :retired]
      default :available
      public? true
    end
    attribute :last_odometer_update, :utc_datetime, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_overdue_service
    # TODO: 不支持的 calculation 表达式 :total_service_cost
    # TODO: 不支持的 calculation 表达式 :days_until_next_service
  end

  relationships do
    belongs_to :vehicle_type, UniboV4.Fleet.FleetVehicleType do
      public? true
    end
    has_many :assignments, UniboV4.Fleet.VehicleAssignment do
      public? true
      destination_attribute :fleet_vehicle_id
    end
    has_many :services, UniboV4.Fleet.VehicleService do
      public? true
      destination_attribute :fleet_vehicle_id
    end
    has_many :contracts, UniboV4.Fleet.VehicleContract do
      public? true
      destination_attribute :fleet_vehicle_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :license_plate, :brand, :model_name, :model_year, :vin, :purchase_date, :acquisition_cost, :fuel_type, :color, :seats, :odometer, :garage_id]
      argument :fleet_vehicle_type_id, :string
      validate present(:license_plate)
      validate present(:name)
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
      accept [:name, :license_plate, :brand, :model_name, :model_year, :odometer, :fuel_type, :color, :seats, :status, :garage_id, :last_odometer_update, :next_service_date]
      argument :fleet_vehicle_type_id, :string
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
    update :decommission do
      accept [:decommission_date]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:available, :in_use, :maintenance] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:available, :in_use, :maintenance]}))
        end
      end
      # message: "只有非报废状态的车辆可以报废"
      change set_attribute(:status, :retired)
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

  identities do
    identity :unique_license_plate, [:license_plate]
    identity :unique_vin, [:vin]
  end

end
