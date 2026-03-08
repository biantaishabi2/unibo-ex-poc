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
defmodule UniboExPoc.Maintenance.Vehicle do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "车辆（Fleet 管理），动态状态，驾驶员变更自动记录历史"
  end

  postgres do
    table "maintenance_vehicles"
    repo UniboExPoc.Repo
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
    attribute :name, :string do
      public? true
      description "车辆显示名（自动生成）"
    end
    attribute :vehicle_code, :string do
      allow_nil? false
      public? true
      description "车辆编号"
    end
    attribute :license_plate, :string do
      public? true
      description "车牌号"
    end
    attribute :vin_sn, :string do
      public? true
      description "车架号"
    end
    attribute :acquisition_date, :date do
      public? true
      description "购入日期"
    end
    attribute :vehicle_type, :atom do
      constraints one_of: [:car, :bike]
      default :car
      public? true
      description "车辆类型"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :transmission, :atom do
      constraints one_of: [:manual, :automatic, :cvt]
      public? true
      description "变速箱类型（从 model 继承）"
    end
    attribute :model_year, :integer do
      public? true
      description "年款（从 model 继承）"
    end
    attribute :electric_assistance, :boolean do
      public? true
      description "电动辅助（从 model 继承）"
    end
    attribute :color, :string do
      public? true
      description "颜色（从 model 继承）"
    end
    attribute :seats, :integer do
      public? true
      description "座位数（从 model 继承）"
    end
    attribute :doors, :integer do
      public? true
      description "车门数（从 model 继承）"
    end
    attribute :trailer_hook, :boolean do
      public? true
      description "拖钩（从 model 继承）"
    end
    attribute :co2, :float do
      public? true
      description "碳排放量（从 model 继承）"
    end
    attribute :co2_standard, :string do
      public? true
      description "碳排放标准（从 model 继承）"
    end
    attribute :fuel_type, :atom do
      constraints one_of: [:gasoline, :diesel, :electric, :hybrid, :hydrogen, :lpg, :cng]
      public? true
      description "燃料类型（从 model 继承）"
    end
    attribute :power, :integer do
      public? true
      description "功率（从 model 继承）"
    end
    attribute :horsepower, :float do
      public? true
      description "马力（从 model 继承）"
    end
    attribute :horsepower_tax, :float do
      public? true
      description "马力税（从 model 继承）"
    end
    attribute :odometer, :float do
      public? true
      description "当前里程（最新一条 Odometer 记录的 value）"
    end
    attribute :odometer_unit, :atom do
      constraints one_of: [:kilometers, :miles]
      default :kilometers
      public? true
      description "里程单位"
    end
    attribute :odometer_count, :integer do
      public? true
      description "里程记录数"
    end
    attribute :service_count, :integer do
      public? true
      description "服务记录数"
    end
    attribute :contract_count, :integer do
      public? true
      description "合同数（排除已关闭）"
    end
    attribute :history_count, :integer do
      public? true
      description "分配历史数"
    end
    attribute :contract_renewal_overdue, :boolean do
      public? true
      description "合同已过期"
    end
    attribute :contract_renewal_due_soon, :boolean do
      public? true
      description "合同即将到期"
    end
    attribute :service_activity, :atom do
      constraints one_of: [:none, :overdue, :today]
      public? true
      description "服务活动状态"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :model, UniboExPoc.Maintenance.VehicleModel do
      public? true
      allow_nil? false
    end
    belongs_to :state, UniboExPoc.Maintenance.VehicleState do
      public? true
      allow_nil? false
    end
    belongs_to :driver, UniboExPoc.Maintenance.Party do
      public? true
      source_attribute :driver_party_id
    end
    belongs_to :future_driver, UniboExPoc.Maintenance.Party do
      public? true
      source_attribute :future_driver_party_id
    end
    belongs_to :company, UniboExPoc.Maintenance.Party do
      public? true
      source_attribute :company_party_id
    end
    many_to_many :tags, UniboExPoc.Maintenance.VehicleTag do
      public? true
      through UniboExPoc.Maintenance.VehicleTagLink
    end
    has_many :contracts, UniboExPoc.Maintenance.Contract do
      public? true
    end
    has_many :service_logs, UniboExPoc.Maintenance.ServiceLog do
      public? true
    end
    has_many :odometer_records, UniboExPoc.Maintenance.Odometer do
      public? true
    end
    has_many :assignment_logs, UniboExPoc.Maintenance.AssignmentLog do
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
      change UniboExPoc.Maintenance.Changes.Vehicle.CreateCall1
      change UniboExPoc.Maintenance.Changes.Vehicle.CreateCall3
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:license_plate, :vin_sn, :odometer_unit, :notes]
      change UniboExPoc.Maintenance.Changes.Vehicle.UpdateCall1
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :change_driver do
      description "变更驾驶员"
      argument :driver_id, :uuid
      change UniboExPoc.Maintenance.Changes.Vehicle.ChangeDriverCall1
      change UniboExPoc.Maintenance.Changes.Vehicle.ChangeDriverCall2
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :set_future_driver do
      description "设置计划下一任驾驶员"
      argument :future_driver_id, :uuid
      change UniboExPoc.Maintenance.Changes.Vehicle.SetFutureDriverCall1
      change UniboExPoc.Maintenance.Changes.Vehicle.SetFutureDriverCall4
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :change_state do
      description "变更车辆状态"
      accept [:state_id]
      change UniboExPoc.Maintenance.Changes.Vehicle.ChangeStateCall1
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deactivate do
      description "停用车辆"
      accept []
      change UniboExPoc.Maintenance.Changes.Vehicle.DeactivateCall1
      change set_attribute(:active, false)
      change set_attribute(:active, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :set_odometer do
      description "记录里程（追加写入 Odometer 记录）"
      argument :odometer_value, :string
      # skipped: validate compare :odometer_value (incompatible with bulk update atomic path)
      change UniboExPoc.Maintenance.Changes.Vehicle.SetOdometerCall1
      change UniboExPoc.Maintenance.Changes.Vehicle.SetOdometerCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_vehicle_code, [:vehicle_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
