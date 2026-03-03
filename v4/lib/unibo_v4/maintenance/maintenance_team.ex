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
defmodule UniboV4.Maintenance.MaintenanceTeam do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "maintenance_teams"
    repo UniboV4.Repo
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
    end
    attribute :todo_count, :integer, public?: true
    attribute :scheduled_count, :integer, public?: true
    attribute :unscheduled_count, :integer, public?: true
    attribute :high_priority_count, :integer, public?: true
    attribute :blocked_count, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :maintenance_requests, UniboV4.Maintenance.MaintenanceRequest do
      public? true
    end
    many_to_many :members, UniboV4.Maintenance.User do
      public? true
      through UniboV4.Maintenance.MaintenanceTeamMemberLink
    end
    belongs_to :company, UniboV4.Maintenance.Company do
      public? true
      allow_nil? false
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
      accept [:name]
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
    update :add_member do
      argument :user_id, :string
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
    update :remove_member do
      argument :user_id, :string
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
