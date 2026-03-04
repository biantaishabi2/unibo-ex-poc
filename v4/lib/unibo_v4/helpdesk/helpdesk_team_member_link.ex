defmodule UniboV4.Helpdesk.HelpdeskTeamMemberLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_team_member_links"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :team, UniboV4.Helpdesk.HelpdeskTeam do
      public? true
      allow_nil? false
      source_attribute :helpdesk_team_id
    end
    belongs_to :employee, UniboV4.Helpdesk.Employee do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
