defmodule UniboV4.Marketing do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Marketing.Campaign
    resource UniboV4.Marketing.CampaignRole
    resource UniboV4.Marketing.MailingList
    resource UniboV4.Marketing.MailingListMember
    resource UniboV4.Marketing.Segment
    resource UniboV4.Marketing.Event
    resource UniboV4.Marketing.EventRegistration
  end
end
