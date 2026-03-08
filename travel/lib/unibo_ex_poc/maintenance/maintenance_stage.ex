# Workflow: maintenance_stage_maintain_flow — 维护阶段维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Maintenance.MaintenanceStage do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "维护请求的可配置看板阶段，非固定状态枚举"
  end

  postgres do
    table "maintenance_stages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_maintenance_stage

    queries do
      get :get_maintenance_maintenance_stage, :read
      list :list_maintenance_maintenance_stages, :read
    end

    mutations do
      create :create_maintenance_maintenance_stage, :create
      update :update_maintenance_maintenance_stage, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "阶段名称"
    end
    attribute :sequence, :integer do
      default 0
      public? true
      description "排序，用于看板展示"
    end
    attribute :fold, :boolean do
      default false
      public? true
      description "看板折叠"
    end
    attribute :done, :boolean do
      default false
      public? true
      description "标记该阶段为\"完成\""
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :maintenance_requests, UniboExPoc.Maintenance.MaintenanceRequest do
      public? true
      destination_attribute :stage_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :fold, :done]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sequence, :fold, :done]
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
