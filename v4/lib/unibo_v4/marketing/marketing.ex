defmodule UniboV4.Marketing do
  use Ash.Domain

  resources do
    resource UniboV4.Marketing.Campaign
    resource UniboV4.Marketing.CampaignRole
    resource UniboV4.Marketing.MailingList
    resource UniboV4.Marketing.MailingListMember
    resource UniboV4.Marketing.Mailing
    resource UniboV4.Marketing.MailingTrace
    resource UniboV4.Marketing.Segment
    resource UniboV4.Marketing.Event
    resource UniboV4.Marketing.EventTicket
    resource UniboV4.Marketing.EventMailSchedule
    resource UniboV4.Marketing.EventRegistration
    resource UniboV4.Marketing.SmsMessage
    resource UniboV4.Marketing.SmsTemplate
    resource UniboV4.Marketing.SocialPost
    resource UniboV4.Marketing.SocialAccount
    resource UniboV4.Marketing.AutomationCampaign
    resource UniboV4.Marketing.AutomationActivity
    resource UniboV4.Marketing.AutomationParticipant
    resource UniboV4.Marketing.AutomationTrace
    resource UniboV4.Marketing.UtmCampaign
    resource UniboV4.Marketing.UtmSource
    resource UniboV4.Marketing.UtmMedium
    resource UniboV4.Marketing.UtmTag
    resource UniboV4.Marketing.UtmStage
    resource UniboV4.Marketing.UtmCampaignTagLink
    resource UniboV4.Marketing.EventBoothCategory
    resource UniboV4.Marketing.EventBooth
    resource UniboV4.Marketing.EventTypeBooth
    resource UniboV4.Marketing.EventLeadRule
    resource UniboV4.Marketing.EventLeadRuleEventType
    resource UniboV4.Marketing.MailingContactListLink
    resource UniboV4.Marketing.SocialPostAccountLink
    resource UniboV4.Marketing.User
    resource UniboV4.Marketing.Contact
    resource UniboV4.Marketing.Company
  end
end
