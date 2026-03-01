defmodule UniboV4.CRM do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.CRM.Contact
    resource UniboV4.CRM.ContactAddress
    resource UniboV4.CRM.ContactPhone
    resource UniboV4.CRM.Lead
    resource UniboV4.CRM.LeadStage
    resource UniboV4.CRM.Activity
    resource UniboV4.CRM.SalesForecast
    resource UniboV4.CRM.CalendarEvent
    resource UniboV4.CRM.User
    resource UniboV4.CRM.SalesTeam
    resource UniboV4.CRM.SalesTeamMember
  end
end
