defmodule UniboV4.Helpdesk.TimesheetEntry do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "helpdesk_timesheet_entries"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_timesheet_entry

    queries do
      get :get_helpdesk_timesheet_entry, :read
      list :list_helpdesk_timesheet_entrys, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :ticket, UniboV4.Helpdesk.HelpdeskTicket do
      public? true
      source_attribute :helpdesk_ticket_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
