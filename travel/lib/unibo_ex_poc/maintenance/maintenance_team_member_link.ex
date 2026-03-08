defmodule UniboExPoc.Maintenance.MaintenanceTeamMemberLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "维护团队-成员桥接占位实体"
  end

  postgres do
    table "maintenance_team_member_links"
    repo UniboExPoc.Repo
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
    belongs_to :team, UniboExPoc.Maintenance.MaintenanceTeam do
      public? true
      allow_nil? false
      source_attribute :maintenance_team_id
    end
    belongs_to :user, UniboExPoc.Maintenance.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
