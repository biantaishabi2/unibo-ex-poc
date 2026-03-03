# Workflow: vehicle_lifecycle — 车辆生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> change_driver
#   create --> set_future_driver
#   create --> change_state
#   create --> deactivate
#   create --> set_odometer
#   update --> change_driver
#   update --> set_future_driver
#   update --> change_state
#   update --> deactivate
#   update --> set_odometer
#   change_driver --> update
#   change_driver --> set_future_driver
#   change_driver --> change_state
#   change_driver --> deactivate
#   change_driver --> set_odometer
#   set_future_driver --> change_driver
#   change_state --> update
#   change_state --> deactivate
#   deactivate --> [*]
#   set_odometer --> set_odometer
# ```
defmodule UniboV4.Maintenance.Vehicle do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "maintenance_vehicles"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_vehicle

    queries do
      get :get_maintenance_vehicle, :read
      list :list_maintenance_vehicles, :read
    end

    mutations do
      create :create_maintenance_vehicle, :create
      update :update_maintenance_vehicle, :update
      update :change_driver_maintenance_vehicle, :change_driver
      update :set_future_driver_maintenance_vehicle, :set_future_driver
      update :change_state_maintenance_vehicle, :change_state
      update :deactivate_maintenance_vehicle, :deactivate
      update :set_odometer_maintenance_vehicle, :set_odometer
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :vehicle_code, :string do
      allow_nil? false
      public? true
    end
    attribute :license_plate, :string, public?: true
    attribute :vin_sn, :string, public?: true
    attribute :acquisition_date, :date, public?: true
    attribute :vehicle_type, :atom do
      constraints one_of: [:car, :bike]
      default :car
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :transmission, :atom do
      constraints one_of: [:manual, :automatic, :cvt]
      public? true
    end
    attribute :model_year, :integer, public?: true
    attribute :electric_assistance, :boolean, public?: true
    attribute :color, :string, public?: true
    attribute :seats, :integer, public?: true
    attribute :doors, :integer, public?: true
    attribute :trailer_hook, :boolean, public?: true
    attribute :co2, :float, public?: true
    attribute :co2_standard, :string, public?: true
    attribute :fuel_type, :atom do
      constraints one_of: [:gasoline, :diesel, :electric, :hybrid, :hydrogen, :lpg, :cng]
      public? true
    end
    attribute :power, :integer, public?: true
    attribute :horsepower, :float, public?: true
    attribute :horsepower_tax, :float, public?: true
    attribute :odometer, :float, public?: true
    attribute :odometer_unit, :atom do
      constraints one_of: [:kilometers, :miles]
      default :kilometers
      public? true
    end
    attribute :odometer_count, :integer, public?: true
    attribute :service_count, :integer, public?: true
    attribute :contract_count, :integer, public?: true
    attribute :history_count, :integer, public?: true
    attribute :contract_renewal_overdue, :boolean, public?: true
    attribute :contract_renewal_due_soon, :boolean, public?: true
    attribute :service_activity, :atom do
      constraints one_of: [:none, :overdue, :today]
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :model, UniboV4.Maintenance.VehicleModel do
      public? true
      allow_nil? false
    end
    belongs_to :state, UniboV4.Maintenance.VehicleState do
      public? true
      allow_nil? false
    end
    belongs_to :driver, UniboV4.Maintenance.Partner do
      public? true
    end
    belongs_to :future_driver, UniboV4.Maintenance.Partner do
      public? true
    end
    belongs_to :company, UniboV4.Maintenance.Company do
      public? true
    end
    many_to_many :tags, UniboV4.Maintenance.VehicleTag do
      public? true
      through UniboV4.Maintenance.VehicleTagLink
    end
    has_many :contracts, UniboV4.Maintenance.Contract do
      public? true
    end
    has_many :service_logs, UniboV4.Maintenance.ServiceLog do
      public? true
    end
    has_many :odometer_records, UniboV4.Maintenance.Odometer do
      public? true
    end
    has_many :assignment_logs, UniboV4.Maintenance.AssignmentLog do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:vehicle_code, :license_plate, :vin_sn, :acquisition_date, :vehicle_type, :odometer_unit, :notes]
      argument :model_id, :uuid, allow_nil?: false
      argument :driver_id, :uuid
      change manage_relationship(:model_id, :model, type: :append, on_lookup: :relate)
      argument :state_id, :uuid, allow_nil?: false
      change manage_relationship(:state_id, :state, type: :append, on_lookup: :relate)
      validate present(:vehicle_code)
      # TODO: 不支持的 change effect compute_model_fields
      # TODO: 不支持的 change effect create_driver_history
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
      accept [:license_plate, :vin_sn, :odometer_unit, :notes]
      # TODO: 不支持的 change effect compute_model_fields
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
    update :change_driver do
      argument :driver_id, :uuid
      # TODO: 不支持的 change effect compute_model_fields
      # TODO: 不支持的 change effect create_assignment_log
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
    update :set_future_driver do
      argument :future_driver_id, :uuid
      # TODO: 不支持的 change effect compute_model_fields
      # TODO: 不支持的 change effect set_plan_to_change
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
    update :change_state do
      argument :state_id, :uuid
      # TODO: 不支持的 change effect compute_model_fields
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
    update :deactivate do
      accept []
      # TODO: 不支持的 change effect compute_model_fields
      # TODO: 不支持的 change effect cascade_deactivate
      change set_attribute(:active, false)
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
    update :set_odometer do
      argument :odometer_value, :string
      # skipped: validate positive :odometer_value (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect compute_model_fields
      # TODO: 不支持的 change effect append_odometer
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
    identity :unique_vehicle_code, [:vehicle_code]
  end

end
