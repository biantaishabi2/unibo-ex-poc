defmodule UniboExPoc.CRM do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.CRM.Contact
    resource UniboExPoc.CRM.Contact.Version
    resource UniboExPoc.CRM.ContactAddress
    resource UniboExPoc.CRM.ContactAddress.Version
    resource UniboExPoc.CRM.ContactPhone
    resource UniboExPoc.CRM.ContactPhone.Version
    resource UniboExPoc.CRM.Lead
    resource UniboExPoc.CRM.Lead.Version
    resource UniboExPoc.CRM.LeadStage
    resource UniboExPoc.CRM.LeadStage.Version
    resource UniboExPoc.CRM.Activity
    resource UniboExPoc.CRM.Activity.Version
    resource UniboExPoc.CRM.SalesForecast
    resource UniboExPoc.CRM.SalesForecast.Version
    resource UniboExPoc.CRM.CalendarEvent
    resource UniboExPoc.CRM.SalesTeam
    resource UniboExPoc.CRM.SalesTeam.Version
    resource UniboExPoc.CRM.SalesTeamMember
    resource UniboExPoc.CRM.SalesTeamMember.Version
    resource UniboExPoc.CRM.Party
  end
end
