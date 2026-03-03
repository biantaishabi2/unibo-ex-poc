defmodule UniboV4.Events.Events do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Events.Events.EventType
    resource UniboV4.Events.Events.EventTypeTranslation
    resource UniboV4.Events.Events.Event
    resource UniboV4.Events.Events.EventTranslation
    resource UniboV4.Events.Events.EventRegistration
    resource UniboV4.Events.Events.EventTicket
    resource UniboV4.Events.Events.EventTicketTranslation
    resource UniboV4.Events.Events.EventBooth
    resource UniboV4.Events.Events.EventBoothTranslation
    resource UniboV4.Events.Events.EventStage
    resource UniboV4.Events.Events.EventStageTranslation
  end
end
