defmodule UniboExPoc.IoT do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.IoT.IoTBox
    resource UniboExPoc.IoT.IoTBox.Version
    resource UniboExPoc.IoT.IoTDevice
    resource UniboExPoc.IoT.IoTDevice.Version
    resource UniboExPoc.IoT.TriggerRule
    resource UniboExPoc.IoT.TriggerRule.Version
    resource UniboExPoc.IoT.EventLog
    resource UniboExPoc.IoT.EventLog.Version
    resource UniboExPoc.IoT.VoIPProvider
    resource UniboExPoc.IoT.VoIPProvider.Version
    resource UniboExPoc.IoT.VoIPCall
    resource UniboExPoc.IoT.VoIPCall.Version
    resource UniboExPoc.IoT.CallQueue
    resource UniboExPoc.IoT.CallQueue.Version
    resource UniboExPoc.IoT.QueueMember
    resource UniboExPoc.IoT.QueueMember.Version
    resource UniboExPoc.IoT.VoIPUserConfig
    resource UniboExPoc.IoT.VoIPUserConfig.Version
    resource UniboExPoc.IoT.DialPlan
    resource UniboExPoc.IoT.DialPlan.Version
    resource UniboExPoc.IoT.DialPlanElement
    resource UniboExPoc.IoT.DialPlanElement.Version
    resource UniboExPoc.IoT.IncomingNumber
    resource UniboExPoc.IoT.IncomingNumber.Version
    resource UniboExPoc.IoT.Voicemail
    resource UniboExPoc.IoT.Voicemail.Version
    resource UniboExPoc.IoT.ConferenceRoom
    resource UniboExPoc.IoT.ConferenceRoom.Version
    resource UniboExPoc.IoT.Org
    resource UniboExPoc.IoT.Media
    resource UniboExPoc.IoT.Contact
    resource UniboExPoc.IoT.CrmLead
    resource UniboExPoc.IoT.HelpdeskTicket
    resource UniboExPoc.IoT.Party
  end
end
