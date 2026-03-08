# Workflow: vehicle_assignment_flow — 车辆分配流程
# ```mermaid
# stateDiagram-v2
#   [*] --> assign
#   assign --> return
#   assign --> transfer
#   return --> [*]
#   transfer --> [*]
# ```
defmodule UniboExPoc.Fleet.VehicleAssignment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Fleet.VehicleAssignment.Notifier]

  resource do
    description "车辆分配记录，记录谁用哪辆车、时间段"
  end

  postgres do
    table "fleet_vehicle_assignments"
    repo UniboExPoc.Repo
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
      description "分配开始日期"
    end
    attribute :to_date, :date do
      public? true
      description "分配结束日期"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :returned, :transferred]
      default :active
      public? true
      description "分配状态"
    end
    attribute :notes, :string do
      public? true
      description "备注"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :fleet_vehicle, UniboExPoc.Fleet.FleetVehicle do
      public? true
      allow_nil? false
    end
    belongs_to :driver, UniboExPoc.Fleet.Driver do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :assign do
      description "分配车辆给驾驶员"
      primary? true
      accept [:fleet_vehicle_id, :driver_id, :from_date, :notes]
      argument :fleet_vehicle_id, :uuid, allow_nil?: false
      change manage_relationship(:fleet_vehicle_id, :fleet_vehicle, type: :append, on_lookup: :relate)
      argument :driver_id, :uuid, allow_nil?: false
      change manage_relationship(:driver_id, :driver, type: :append, on_lookup: :relate)
      validate present(:fleet_vehicle_id)
      validate present(:driver_id)
      validate present(:from_date)
      # validation: custom_check — 该车辆已分配给其他驾驶员
      change set_attribute(:status, :active)
      change UniboExPoc.Fleet.Changes.VehicleAssignment.AssignCall2
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
      description "归还车辆"
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
      change UniboExPoc.Fleet.Changes.VehicleAssignment.ReturnCall4
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
      description "转移车辆给其他驾驶员"
      accept [:driver_id, :notes]
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
