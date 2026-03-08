# Workflow: sales_team_lifecycle — 销售团队管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.CRM.SalesTeam do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "销售团队，支持单/多团队模式切换，管理商机分配和销售管道"
  end

  postgres do
    table "crm_sales_teams"
    repo UniboV4.Repo
  end

  graphql do
    type :crm_sales_team

    queries do
      get :get_crm_sales_team, :read
      list :list_crm_sales_teams, :read
    end

    mutations do
      create :create_crm_sales_team, :create
      update :update_crm_sales_team, :update
      destroy :delete_crm_sales_team, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "团队名称（可翻译）"
    end
    attribute :sequence, :integer do
      default 10
      public? true
      description "排序权重"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "活跃状态，归档时置 false"
    end
    attribute :color, :integer do
      default 0
      public? true
      description "看板颜色索引"
    end
    attribute :carrier_description, :string do
      public? true
      description "团队描述"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :leader, UniboV4.CRM.Party do
      public? true
      source_attribute :leader_party_id
    end
    has_many :members, UniboV4.CRM.SalesTeamMember do
      public? true
      source_attribute :leader_party_id
      destination_attribute :team_id
    end
    has_many :leads, UniboV4.CRM.Lead do
      public? true
      source_attribute :leader_party_id
      destination_attribute :team_id
    end
    has_many :stages, UniboV4.CRM.LeadStage do
      public? true
      source_attribute :leader_party_id
      destination_attribute :team_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :sequence, :active, :color, :carrier_description]
      argument :leader_id, :uuid
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sequence, :active, :color, :carrier_description]
      argument :leader_id, :uuid
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
    archive_related [:members, :leads, :stages]
  end

end
