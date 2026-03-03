# Workflow: vehicle_assignment_flow — 车辆分配流程
# ```mermaid
# stateDiagram-v2
#   [*] --> assign
#   assign --> return
#   assign --> transfer
#   return --> [*]
#   transfer --> [*]
# ```
defmodule UniboV4.Fleet.Fleet.VehicleAssignment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Fleet.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Fleet.Fleet.VehicleAssignment.Notifier]

  postgres do
    table "fleet_vehicle_assignments"
    repo UniboV4.Repo
  end

  graphql do
    type :fleet_vehicle_assignment

    queries do
      get :get_fleet_vehicle_assignment, :read
      list :list_fleet_vehicle_assignments, :read
    end

    mutations do
      create :create_assign_fleet_vehicle_assignment, :assign
      update :return_fleet_vehicle_assignment, :return
      update :transfer_fleet_vehicle_assignment, :transfer
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :from_date, :date do
      allow_nil? false
      public? true
    end
    attribute :to_date, :date, public?: true
    attribute :status, :atom do
      constraints one_of: [:active, :returned, :transferred]
      default :active
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :fleet_vehicle, UniboV4.Fleet.Fleet.FleetVehicle do
      public? true
      allow_nil? false
    end
    belongs_to :driver, UniboV4.Fleet.Fleet.Driver do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :assign do
      primary? true
      accept [:from_date, :notes]
      argument :fleet_vehicle_id, :uuid, allow_nil?: false
      change manage_relationship(:fleet_vehicle_id, :fleet_vehicle, type: :append, on_lookup: :relate)
      argument :driver_id, :uuid, allow_nil?: false
      change manage_relationship(:driver_id, :driver, type: :append, on_lookup: :relate)
      validate present(:fleet_vehicle_id)
      validate present(:driver_id)
      validate present(:from_date)
      # TODO: 不支持的 action 内校验规则 custom
      change set_attribute(:status, :active)
      # TODO: 不支持的 change effect set_related
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :return do
      primary? true
      accept [:to_date, :notes]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃的分配可以归还或转移"
      change set_attribute(:status, :returned)
      # TODO: 不支持的 change effect set_related
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
    update :transfer do
      accept [:notes]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃的分配可以归还或转移"
      change set_attribute(:status, :transferred)
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
