# Workflow: vehicle_state_maintain_flow — 车辆状态维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Maintenance.VehicleState do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "车辆状态（动态状态模型，看板分组展开）"
  end

  postgres do
    table "maintenance_vehicle_states"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_vehicle_state

    queries do
      get :get_maintenance_vehicle_state, :read
      list :list_maintenance_vehicle_states, :read
    end

    mutations do
      create :create_maintenance_vehicle_state, :create
      update :update_maintenance_vehicle_state, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "状态名称"
    end
    attribute :sequence, :integer do
      default 0
      public? true
      description "排序"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :vehicles, UniboExPoc.Maintenance.Vehicle do
      public? true
      destination_attribute :state_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sequence]
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
