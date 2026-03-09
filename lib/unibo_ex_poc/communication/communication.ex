defmodule UniboExPoc.Communication do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Communication.Channel
    resource UniboExPoc.Communication.Channel.Version
    resource UniboExPoc.Communication.ChannelMember
    resource UniboExPoc.Communication.ChannelMember.Version
    resource UniboExPoc.Communication.Message
    resource UniboExPoc.Communication.Message.Version
    resource UniboExPoc.Communication.MailGroup
    resource UniboExPoc.Communication.MailGroup.Version
    resource UniboExPoc.Communication.MailGroupMember
    resource UniboExPoc.Communication.MailGroupMember.Version
    resource UniboExPoc.Communication.MailGroupMessage
    resource UniboExPoc.Communication.MailGroupMessage.Version
    resource UniboExPoc.Communication.MailGroupModeration
    resource UniboExPoc.Communication.MailGroupModeration.Version
    resource UniboExPoc.Communication.Attachment
    resource UniboExPoc.Communication.Notification
    resource UniboExPoc.Communication.TrackingValue
    resource UniboExPoc.Communication.Guest
    resource UniboExPoc.Communication.Group
    resource UniboExPoc.Communication.RTCSession
    resource UniboExPoc.Communication.MessageSubtype
    resource UniboExPoc.Communication.Party
  end
end
