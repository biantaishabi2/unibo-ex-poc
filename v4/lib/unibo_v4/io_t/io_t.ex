defmodule UniboV4.IoT do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.IoT.IoTBox
    resource UniboV4.IoT.IoTDevice
    resource UniboV4.IoT.TriggerRule
    resource UniboV4.IoT.EventLog
    resource UniboV4.IoT.VoIPProvider
    resource UniboV4.IoT.VoIPCall
    resource UniboV4.IoT.CallQueue
    resource UniboV4.IoT.QueueMember
    resource UniboV4.IoT.User
    resource UniboV4.IoT.Org
    resource UniboV4.IoT.Media
    resource UniboV4.IoT.Contact
    resource UniboV4.IoT.CrmLead
    resource UniboV4.IoT.HelpdeskTicket
  end
end
