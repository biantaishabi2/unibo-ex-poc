# Workflow: quality_team_maintain_flow — 质量团队维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Quality.QualityTeam do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "质量团队，用于分配警报和检查"
  end

  postgres do
    table "quality_teams"
    repo UniboExPoc.Repo
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
      description "团队名称"
    end
    attribute :alias_email, :string do
      public? true
      description "团队邮箱别名，用于通知"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    many_to_many :members, UniboExPoc.Quality.Party do
      public? true
      through UniboExPoc.Quality.QualityTeamMemberLink
      destination_attribute_on_join_resource :member_party_id
    end
    has_many :quality_points, UniboExPoc.Quality.QualityPoint do
      public? true
      destination_attribute :team_id
    end
    has_many :quality_checks, UniboExPoc.Quality.QualityCheck do
      public? true
      destination_attribute :team_id
    end
    has_many :quality_alerts, UniboExPoc.Quality.QualityAlert do
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:quality_points, :quality_checks, :quality_alerts]
  end

end
