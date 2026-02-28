defmodule UniboV4.Helpdesk do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Helpdesk.Ticket
    resource UniboV4.Helpdesk.TicketCategory
    resource UniboV4.Helpdesk.FieldServiceOrder
    resource UniboV4.Helpdesk.FieldServiceAssignment
    resource UniboV4.Helpdesk.Appointment
  end
end
