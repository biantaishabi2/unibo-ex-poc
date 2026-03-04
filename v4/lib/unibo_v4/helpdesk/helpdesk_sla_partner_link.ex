defmodule UniboV4.Helpdesk.HelpdeskSLAPartnerLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_sla_partner_links"
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
    belongs_to :partner, UniboV4.Helpdesk.Partner do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
