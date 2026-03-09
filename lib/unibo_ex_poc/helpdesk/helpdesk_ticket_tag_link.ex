defmodule UniboExPoc.Helpdesk.HelpdeskTicketTagLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "工单-标签桥接占位实体"
  end

  postgres do
    table "helpdesk_ticket_tag_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_helpdesk_ticket_tag_link

    queries do
      get :get_helpdesk_helpdesk_ticket_tag_link, :read
      list :list_helpdesk_helpdesk_ticket_tag_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :ticket, UniboExPoc.Helpdesk.HelpdeskTicket do
      public? true
      allow_nil? false
      source_attribute :helpdesk_ticket_id
    end
    belongs_to :tag, UniboExPoc.Helpdesk.HelpdeskTag do
      public? true
      allow_nil? false
      source_attribute :helpdesk_tag_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
