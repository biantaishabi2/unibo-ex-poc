# Workflow: assignment_log_creation_flow — 驾驶员分配记录创建
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Maintenance.AssignmentLog do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "车辆驾驶员分配历史，纯日志模型，由 Vehicle 驾驶员变更自动创建"
  end

  postgres do
    table "maintenance_assignment_logs"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_assignment_log

    queries do
      get :get_maintenance_assignment_log, :read
      list :list_maintenance_assignment_logs, :read
    end

    mutations do
      create :create_maintenance_assignment_log, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :date_start, :date do
      public? true
      description "分配开始日期"
    end
    attribute :date_end, :date do
      public? true
      description "分配结束日期"
    end
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :vehicle, UniboV4.Maintenance.Vehicle do
      public? true
      allow_nil? false
    end
    belongs_to :driver, UniboV4.Maintenance.Party do
      public? true
      allow_nil? false
      source_attribute :driver_party_id
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:date_start, :date_end]
      argument :vehicle_id, :uuid, allow_nil?: false
      argument :driver_id, :uuid, allow_nil?: false
      change manage_relationship(:vehicle_id, :vehicle, type: :append, on_lookup: :relate)
      change manage_relationship(:driver_id, :driver, type: :append, on_lookup: :relate)
      validate present(:date_start)
      change set_attribute(:id, expr(id))
    end
  end

end
