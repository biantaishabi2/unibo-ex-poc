# Workflow: quality_team_maintain_flow — 质量团队维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Quality.QualityTeam do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "quality_teams"
    repo UniboV4.Repo
  end

  graphql do
    type :quality_quality_team

    queries do
      get :get_quality_quality_team, :read
      list :list_quality_quality_teams, :read
    end

    mutations do
      create :create_quality_quality_team, :create
      update :update_quality_quality_team, :update
      destroy :delete_quality_quality_team, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :alias_email, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :members, UniboV4.Quality.User do
      public? true
      through UniboV4.Quality.QualityTeamMemberLink
    end
    has_many :quality_points, UniboV4.Quality.QualityPoint do
      public? true
      destination_attribute :team_id
    end
    has_many :quality_checks, UniboV4.Quality.QualityCheck do
      public? true
      destination_attribute :team_id
    end
    has_many :quality_alerts, UniboV4.Quality.QualityAlert do
      public? true
      destination_attribute :team_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :alias_email]
      argument :member_ids, {:array, :string}
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
      accept [:name, :alias_email]
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

  identities do
    identity :unique_team_name, [:name]
  end

end
