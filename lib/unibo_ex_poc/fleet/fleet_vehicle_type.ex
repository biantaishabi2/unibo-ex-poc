# Workflow: fleet_vehicle_type_lifecycle — 车队车辆类型维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Fleet.FleetVehicleType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "车队车辆类型（轿车、货车、电动车等）"
  end

  postgres do
    table "fleet_vehicle_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :fleet_fleet_vehicle_type

    queries do
      get :get_fleet_fleet_vehicle_type, :read
      list :list_fleet_fleet_vehicle_types, :read
    end

    mutations do
      create :create_fleet_fleet_vehicle_type, :create
      update :update_fleet_fleet_vehicle_type, :update
      destroy :delete_fleet_fleet_vehicle_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "类型名称"
    end
    attribute :description, :string do
      public? true
      description "类型描述"
    end
    attribute :parent_type_id, :uuid do
      public? true
      description "父类型（支持多级分类）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :translations, UniboExPoc.Fleet.FleetVehicleTypeTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :parent_type_id]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :parent_type_id]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
