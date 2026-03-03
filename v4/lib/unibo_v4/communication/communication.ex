defmodule UniboV4.Communication do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Communication.Channel
    resource UniboV4.Communication.ChannelMember
    resource UniboV4.Communication.Message
    resource UniboV4.Communication.MailGroup
    resource UniboV4.Communication.MailGroupMember
    resource UniboV4.Communication.MailGroupMessage
    resource UniboV4.Communication.MailGroupModeration
    resource UniboV4.Communication.ResPartner
    resource UniboV4.Communication.Attachment
    resource UniboV4.Communication.Notification
    resource UniboV4.Communication.TrackingValue
    resource UniboV4.Communication.User
    resource UniboV4.Communication.Guest
  end
end
