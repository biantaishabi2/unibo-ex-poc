defmodule UniboV4.IoT do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.IoT.IoTBox
    resource UniboV4.IoT.IoTBox.Version
    resource UniboV4.IoT.IoTDevice
    resource UniboV4.IoT.IoTDevice.Version
    resource UniboV4.IoT.TriggerRule
    resource UniboV4.IoT.TriggerRule.Version
    resource UniboV4.IoT.EventLog
    resource UniboV4.IoT.EventLog.Version
    resource UniboV4.IoT.VoIPProvider
    resource UniboV4.IoT.VoIPProvider.Version
    resource UniboV4.IoT.VoIPCall
    resource UniboV4.IoT.VoIPCall.Version
    resource UniboV4.IoT.CallQueue
    resource UniboV4.IoT.CallQueue.Version
    resource UniboV4.IoT.QueueMember
    resource UniboV4.IoT.QueueMember.Version
    resource UniboV4.IoT.VoIPUserConfig
    resource UniboV4.IoT.VoIPUserConfig.Version
    resource UniboV4.IoT.DialPlan
    resource UniboV4.IoT.DialPlan.Version
    resource UniboV4.IoT.DialPlanElement
    resource UniboV4.IoT.DialPlanElement.Version
    resource UniboV4.IoT.IncomingNumber
    resource UniboV4.IoT.IncomingNumber.Version
    resource UniboV4.IoT.Voicemail
    resource UniboV4.IoT.Voicemail.Version
    resource UniboV4.IoT.ConferenceRoom
    resource UniboV4.IoT.ConferenceRoom.Version
    resource UniboV4.IoT.Org
    resource UniboV4.IoT.Media
    resource UniboV4.IoT.Contact
    resource UniboV4.IoT.CrmLead
    resource UniboV4.IoT.HelpdeskTicket
    resource UniboV4.IoT.Party
  end
end
