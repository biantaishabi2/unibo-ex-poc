defmodule UniboV4.Maintenance.MaintenanceTeamMemberLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "maintenance_team_member_links"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_maintenance_team_member_link

    queries do
      get :get_maintenance_maintenance_team_member_link, :read
      list :list_maintenance_maintenance_team_member_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :team, UniboV4.Maintenance.MaintenanceTeam do
      public? true
      allow_nil? false
      source_attribute :maintenance_team_id
    end
    belongs_to :user, UniboV4.Maintenance.User do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
