# Workflow: vehicle_model_maintain_flow — 车辆模型维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Maintenance.VehicleModel do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "车型模板，16 个字段自动传播到 Vehicle"
  end

  postgres do
    table "maintenance_vehicle_models"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_vehicle_model

    queries do
      get :get_maintenance_vehicle_model, :read
      list :list_maintenance_vehicle_models, :read
    end

    mutations do
      create :create_maintenance_vehicle_model, :create
      update :update_maintenance_vehicle_model, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "型号名称"
    end
    attribute :vehicle_type, :atom do
      constraints one_of: [:car, :bike]
      default :car
      public? true
      description "车辆类型"
    end
    attribute :transmission, :atom do
      constraints one_of: [:manual, :automatic, :cvt]
      public? true
      description "变速箱类型"
    end
    attribute :model_year, :integer do
      public? true
      description "年款"
    end
    attribute :electric_assistance, :boolean do
      default false
      public? true
      description "电动辅助"
    end
    attribute :color, :string do
      public? true
      description "颜色"
    end
    attribute :seats, :integer do
      public? true
      description "座位数"
    end
    attribute :doors, :integer do
      public? true
      description "车门数"
    end
    attribute :trailer_hook, :boolean do
      default false
      public? true
      description "拖钩"
    end
    attribute :co2, :float do
      public? true
      description "碳排放量"
    end
    attribute :co2_standard, :string do
      public? true
      description "碳排放标准"
    end
    attribute :fuel_type, :atom do
      constraints one_of: [:gasoline, :diesel, :electric, :hybrid, :hydrogen, :lpg, :cng]
      public? true
      description "燃料类型"
    end
    attribute :power, :integer do
      public? true
      description "功率 (kW)"
    end
    attribute :horsepower, :float do
      public? true
      description "马力"
    end
    attribute :horsepower_tax, :float do
      public? true
      description "马力税"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :brand, UniboExPoc.Maintenance.VehicleModelBrand do
      public? true
    end
    belongs_to :category, UniboExPoc.Maintenance.VehicleModelCategory do
      public? true
    end
    has_many :vehicles, UniboExPoc.Maintenance.Vehicle do
      public? true
      destination_attribute :model_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :vehicle_type, :transmission, :model_year, :electric_assistance, :color, :seats, :doors, :trailer_hook, :co2, :co2_standard, :fuel_type, :power, :horsepower, :horsepower_tax]
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
      accept [:name, :vehicle_type, :transmission, :model_year, :electric_assistance, :color, :seats, :doors, :trailer_hook, :co2, :co2_standard, :fuel_type, :power, :horsepower, :horsepower_tax]
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
