defmodule UniboV4.Helpdesk.HelpdeskSLAExcludeStageLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "helpdesk_sla_exclude_stage_links"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_helpdesk_sla_exclude_stage_link

    queries do
      get :get_helpdesk_helpdesk_sla_exclude_stage_link, :read
      list :list_helpdesk_helpdesk_sla_exclude_stage_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :sla, UniboV4.Helpdesk.HelpdeskSLA do
      public? true
      allow_nil? false
      source_attribute :helpdesk_sla_id
    end
    belongs_to :stage, UniboV4.Helpdesk.HelpdeskStage do
      public? true
      allow_nil? false
      source_attribute :helpdesk_stage_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
