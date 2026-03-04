defmodule UniboV4.Helpdesk.HelpdeskSLAExcludeStageLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_sla_exclude_stage_links"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
