# Workflow: vehicle_service_flow — 车辆服务流程
# ```mermaid
# stateDiagram-v2
#   [*] --> schedule
#   schedule --> start
#   schedule --> complete
#   schedule --> cancel
#   start --> complete
#   complete --> [*]
#   cancel --> [*]
# ```
defmodule UniboV4.Fleet.VehicleService do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Fleet.VehicleService.Notifier]

  postgres do
    table "fleet_vehicle_services"
    repo UniboV4.Repo
  end

  graphql do
    type :fleet_vehicle_service

    queries do
      get :get_fleet_vehicle_service, :read
      list :list_fleet_vehicle_services, :read
    end

    mutations do
      create :create_schedule_fleet_vehicle_service, :schedule
      update :start_fleet_vehicle_service, :start
      update :complete_fleet_vehicle_service, :complete
      update :cancel_fleet_vehicle_service, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :service_type, :atom do
      allow_nil? false
      constraints one_of: [:maintenance, :repair, :inspection, :other]
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:scheduled, :in_progress, :completed, :cancelled]
      default :scheduled
      public? true
    end
    attribute :scheduled_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :completed_date, :utc_datetime, public?: true
    attribute :odometer_at_service, :decimal, public?: true
    attribute :interval_quantity, :decimal, public?: true
    attribute :interval_uom_id, :string, public?: true
    attribute :cost, :decimal, public?: true
    attribute :vendor, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :fleet_vehicle, UniboV4.Fleet.FleetVehicle do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :schedule do
      primary? true
      accept [:service_type, :scheduled_date, :odometer_at_service, :interval_quantity, :interval_uom_id, :vendor, :notes]
      argument :fleet_vehicle_id, :uuid, allow_nil?: false
      change manage_relationship(:fleet_vehicle_id, :fleet_vehicle, type: :append, on_lookup: :relate)
      validate present(:fleet_vehicle_id)
      validate present(:service_type)
      validate present(:scheduled_date)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :start do
      primary? true
      accept [:notes]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :scheduled do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :scheduled}))
        end
      end
      # message: "只有已预约的服务可以开始"
      change set_attribute(:status, :in_progress)
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
    update :complete do
      accept [:completed_date, :odometer_at_service, :cost, :notes]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:scheduled, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:scheduled, :in_progress]}))
        end
      end
      # message: "只有已预约或进行中的服务可以完成"
      change set_attribute(:status, :completed)
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
    update :cancel do
      accept [:notes]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :scheduled do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :scheduled}))
        end
      end
      # message: "只有已预约的服务可以取消"
      change set_attribute(:status, :cancelled)
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
