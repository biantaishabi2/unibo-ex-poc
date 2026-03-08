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
defmodule UniboExPoc.Fleet.VehicleService do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Fleet.VehicleService.Notifier]

  resource do
    description "车辆服务记录（保养/维修/年检），来源于 OFBiz FixedAssetMaint"
  end

  postgres do
    table "fleet_vehicle_services"
    repo UniboExPoc.Repo
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
      description "服务类型（对应 product_maint_type_id）"
    end
    attribute :status, :atom do
      constraints one_of: [:scheduled, :in_progress, :completed, :cancelled]
      default :scheduled
      public? true
      description "服务状态"
    end
    attribute :scheduled_date, :utc_datetime do
      allow_nil? false
      public? true
      description "计划日期（对应 schedule_work_effort）"
    end
    attribute :completed_date, :utc_datetime do
      public? true
      description "完成日期"
    end
    attribute :odometer_at_service, :decimal do
      public? true
      description "服务时里程数"
    end
    attribute :interval_quantity, :decimal do
      public? true
      description "保养间隔数量（如每 5000 公里）"
    end
    attribute :interval_uom_id, :string do
      public? true
      description "间隔单位（km / month）"
    end
    attribute :cost, :decimal do
      public? true
      description "服务费用"
    end
    attribute :vendor, :string do
      public? true
      description "服务供应商"
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
  end

  actions do
    defaults [:read]
    create :schedule do
      description "预约服务"
      primary? true
      accept [:fleet_vehicle_id, :service_type, :scheduled_date, :odometer_at_service, :interval_quantity, :interval_uom_id, :vendor, :notes]
      argument :fleet_vehicle_id, :uuid, allow_nil?: false
      change manage_relationship(:fleet_vehicle_id, :fleet_vehicle, type: :append, on_lookup: :relate)
      validate present(:fleet_vehicle_id)
      validate present(:service_type)
      validate present(:scheduled_date)
      change set_attribute(:id, expr(id))
    end
    update :start do
      description "开始服务（scheduled -> in_progress）"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :complete do
      description "完成服务"
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
      change UniboExPoc.Fleet.Changes.VehicleService.CompleteCall3
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消服务"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
