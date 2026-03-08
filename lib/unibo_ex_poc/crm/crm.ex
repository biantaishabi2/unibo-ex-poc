defmodule UniboV4.CRM do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.CRM.Contact
    resource UniboV4.CRM.Contact.Version
    resource UniboV4.CRM.ContactAddress
    resource UniboV4.CRM.ContactAddress.Version
    resource UniboV4.CRM.ContactPhone
    resource UniboV4.CRM.ContactPhone.Version
    resource UniboV4.CRM.Lead
    resource UniboV4.CRM.Lead.Version
    resource UniboV4.CRM.LeadStage
    resource UniboV4.CRM.LeadStage.Version
    resource UniboV4.CRM.Activity
    resource UniboV4.CRM.Activity.Version
    resource UniboV4.CRM.SalesForecast
    resource UniboV4.CRM.SalesForecast.Version
    resource UniboV4.CRM.CalendarEvent
    resource UniboV4.CRM.SalesTeam
    resource UniboV4.CRM.SalesTeam.Version
    resource UniboV4.CRM.SalesTeamMember
    resource UniboV4.CRM.SalesTeamMember.Version
    resource UniboV4.CRM.Party
  end
end
