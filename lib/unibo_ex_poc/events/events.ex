defmodule UniboExPoc.Events do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Events.EventType
    resource UniboExPoc.Events.EventTypeTranslation
    resource UniboExPoc.Events.EventType.Version
    resource UniboExPoc.Events.Event
    resource UniboExPoc.Events.EventTranslation
    resource UniboExPoc.Events.Event.Version
    resource UniboExPoc.Events.EventRegistration
    resource UniboExPoc.Events.EventRegistration.Version
    resource UniboExPoc.Events.EventTicket
    resource UniboExPoc.Events.EventTicketTranslation
    resource UniboExPoc.Events.EventTicket.Version
    resource UniboExPoc.Events.EventBooth
    resource UniboExPoc.Events.EventBoothTranslation
    resource UniboExPoc.Events.EventBooth.Version
    resource UniboExPoc.Events.EventStage
    resource UniboExPoc.Events.EventStageTranslation
    resource UniboExPoc.Events.EventStage.Version
    resource UniboExPoc.Events.Facility
    resource UniboExPoc.Events.Party
  end
end
