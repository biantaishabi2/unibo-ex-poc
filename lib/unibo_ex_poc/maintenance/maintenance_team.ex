# Workflow: maintenance_team_lifecycle — 维护团队管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> add_member
#   update --> add_member
#   add_member --> remove_member
#   add_member --> add_member
#   remove_member --> add_member
# ```
defmodule UniboExPoc.Maintenance.MaintenanceTeam do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "维护团队，含看板仪表盘聚合计算"
  end

  postgres do
    table "maintenance_teams"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_maintenance_team

    queries do
      get :get_maintenance_maintenance_team, :read
      list :list_maintenance_maintenance_teams, :read
    end

    mutations do
      create :create_maintenance_maintenance_team, :create
      update :update_maintenance_maintenance_team, :update
      update :add_member_maintenance_maintenance_team, :add_member
      update :remove_member_maintenance_maintenance_team, :remove_member
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "团队名称"
    end
    attribute :todo_count, :integer do
      public? true
      description "未完成请求数"
    end
    attribute :scheduled_count, :integer do
      public? true
      description "预防性未完成请求数"
    end
    attribute :unscheduled_count, :integer do
      public? true
      description "纠正性未完成请求数"
    end
    attribute :high_priority_count, :integer do
      public? true
      description "高优先级未完成请求数"
    end
    attribute :blocked_count, :integer do
      public? true
      description "阻塞的未完成请求数"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :maintenance_requests, UniboExPoc.Maintenance.MaintenanceRequest do
      public? true
    end
    many_to_many :members, UniboExPoc.Maintenance.Party do
      public? true
      through UniboExPoc.Maintenance.MaintenanceTeamMemberLink
      destination_attribute_on_join_resource :user_party_id
    end
    belongs_to :company, UniboExPoc.Maintenance.Party do
      public? true
      allow_nil? false
      source_attribute :company_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name]
      argument :company_id, :uuid, allow_nil?: false
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :add_member do
      description "添加团队成员"
      argument :user_id, :string
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :remove_member do
      description "移除团队成员"
      argument :user_id, :string
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
