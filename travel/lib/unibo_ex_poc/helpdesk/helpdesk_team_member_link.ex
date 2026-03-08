defmodule UniboExPoc.Helpdesk.HelpdeskTeamMemberLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "团队-成员桥接占位实体"
  end

  postgres do
    table "helpdesk_team_member_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_helpdesk_team_member_link

    queries do
      get :get_helpdesk_helpdesk_team_member_link, :read
      list :list_helpdesk_helpdesk_team_member_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :team, UniboExPoc.Helpdesk.HelpdeskTeam do
      public? true
      allow_nil? false
      source_attribute :helpdesk_team_id
    end
    belongs_to :employee, UniboExPoc.Helpdesk.Employee do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
