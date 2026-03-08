# Workflow: fleet_vehicle_lifecycle — 车队车辆生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> decommission
#   update --> decommission
#   decommission --> [*]
# ```
defmodule UniboExPoc.Fleet.FleetVehicle do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Fleet.FleetVehicle.Notifier]

  resource do
    description "车队车辆主数据，来源于 OFBiz FixedAsset，过滤类型为 FLEET_VEHICLE（区别于 Maintenance 域的 VEHICLE）"
  end

  postgres do
    table "fleet_vehicles"
    repo UniboExPoc.Repo
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
      description "车辆名称（对齐 FixedAsset.fixed_asset_name）"
    end
    attribute :vin, :string do
      public? true
      description "车架号（对齐 FixedAsset.serial_number）"
    end
    attribute :purchase_date, :date do
      public? true
      description "购置日期（对齐 FixedAsset.date_acquired）"
    end
    attribute :last_service_date, :utc_datetime do
      public? true
      description "最近一次保养日期（对齐 FixedAsset.date_last_serviced）"
    end
    attribute :next_service_date, :utc_datetime do
      public? true
      description "下次保养计划日期（对齐 FixedAsset.date_next_service）"
    end
    attribute :decommission_date, :date do
      public? true
      description "预计报废日期（对齐 FixedAsset.expected_end_of_life）"
    end
    attribute :acquisition_cost, :decimal do
      public? true
      description "购置成本（对齐 FixedAsset.purchase_cost）"
    end
    attribute :garage_id, :string do
      public? true
      description "停放车库/设施（对齐 FixedAsset.located_at_facility_id）"
    end
    attribute :license_plate, :string do
      allow_nil? false
      public? true
      description "车牌号"
    end
    attribute :brand, :string do
      public? true
      description "品牌（Toyota、BYD 等）"
    end
    attribute :model_name, :string do
      public? true
      description "型号（Corolla、Han 等）"
    end
    attribute :model_year, :integer do
      public? true
      description "出厂年份"
    end
    attribute :odometer, :decimal do
      default 0
      public? true
      description "当前里程（km）"
    end
    attribute :fuel_type, :atom do
      constraints one_of: [:gasoline, :diesel, :electric, :hybrid, :cng]
      public? true
      description "燃料类型"
    end
    attribute :color, :string do
      public? true
      description "车身颜色"
    end
    attribute :seats, :integer do
      public? true
      description "座位数"
    end
    attribute :status, :atom do
      constraints one_of: [:available, :in_use, :maintenance, :retired]
      default :available
      public? true
      description "车辆状态"
    end
    attribute :last_odometer_update, :utc_datetime do
      public? true
      description "里程更新时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :is_overdue_service, :boolean, expr(is_past(next_service_date))
    calculate :total_service_cost, :decimal, {UniboExPoc.Fleet.Calculations.FleetVehicle.TotalServiceCost, []}
    calculate :days_until_next_service, :integer, expr(date_diff_days(next_service_date, now()))
  end

  relationships do
    belongs_to :vehicle_type, UniboExPoc.Fleet.FleetVehicleType do
      public? true
    end
    has_many :assignments, UniboExPoc.Fleet.VehicleAssignment do
      public? true
      source_attribute :vehicle_type_id
      destination_attribute :fleet_vehicle_id
    end
    has_many :services, UniboExPoc.Fleet.VehicleService do
      public? true
      source_attribute :vehicle_type_id
      destination_attribute :fleet_vehicle_id
    end
    has_many :contracts, UniboExPoc.Fleet.VehicleContract do
      public? true
      source_attribute :vehicle_type_id
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
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :license_plate, :brand, :model_name, :model_year, :odometer, :fuel_type, :color, :seats, :status, :garage_id, :last_odometer_update, :next_service_date]
      argument :fleet_vehicle_type_id, :string
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :decommission do
      description "报废/停用车辆"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_license_plate, [:license_plate]
    identity :unique_vin, [:vin]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
