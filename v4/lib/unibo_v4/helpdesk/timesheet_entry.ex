defmodule UniboV4.Helpdesk.TimesheetEntry do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_timesheet_entries"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
