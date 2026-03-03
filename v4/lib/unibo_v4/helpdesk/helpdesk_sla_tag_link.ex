defmodule UniboV4.Helpdesk.HelpdeskSLATagLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "helpdesk_sla_tag_links"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_helpdesk_sla_tag_link

    queries do
      get :get_helpdesk_helpdesk_sla_tag_link, :read
      list :list_helpdesk_helpdesk_sla_tag_links, :read
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
    belongs_to :tag, UniboV4.Helpdesk.HelpdeskTag do
      public? true
      allow_nil? false
      source_attribute :helpdesk_tag_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
