defmodule UniboV4.Helpdesk.HelpdeskSLAPartnerLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "SLA-伙伴桥接占位实体"
  end

  postgres do
    table "helpdesk_sla_partner_links"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_helpdesk_sla_partner_link

    queries do
      get :get_helpdesk_helpdesk_sla_partner_link, :read
      list :list_helpdesk_helpdesk_sla_partner_links, :read
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
    belongs_to :partner, UniboV4.Helpdesk.Party do
      public? true
      allow_nil? false
      source_attribute :partner_party_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
