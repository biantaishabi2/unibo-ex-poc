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
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    end
    attribute :sequence, :integer do
      default 10
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :color, :integer do
      default 0
      public? true
    end
    attribute :carrier_description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :leader, UniboV4.CRM.User do
      public? true
    end
    has_many :members, UniboV4.CRM.SalesTeamMember do
      public? true
      destination_attribute :team_id
    end
    has_many :leads, UniboV4.CRM.Lead do
      public? true
      destination_attribute :team_id
    end
    has_many :stages, UniboV4.CRM.LeadStage do
      public? true
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
      accept [:name, :sequence, :active, :color, :carrier_description]
      argument :leader_id, :uuid
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

end
