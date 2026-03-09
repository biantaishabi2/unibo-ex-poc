defmodule UniboExPoc.Helpdesk.HelpdeskSLAExcludeStageLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "SLA-排除阶段桥接占位实体"
  end

  postgres do
    table "helpdesk_sla_exclude_stage_links"
    repo UniboExPoc.Repo
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
    belongs_to :sla, UniboExPoc.Helpdesk.HelpdeskSLA do
      public? true
      allow_nil? false
      source_attribute :helpdesk_sla_id
    end
    belongs_to :stage, UniboExPoc.Helpdesk.HelpdeskStage do
      public? true
      allow_nil? false
      source_attribute :helpdesk_stage_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
