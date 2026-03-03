defmodule UniboV4.Events do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Events.EventType
    resource UniboV4.Events.EventTypeTranslation
    resource UniboV4.Events.Event
    resource UniboV4.Events.EventTranslation
    resource UniboV4.Events.EventRegistration
    resource UniboV4.Events.EventTicket
    resource UniboV4.Events.EventTicketTranslation
    resource UniboV4.Events.EventBooth
    resource UniboV4.Events.EventBoothTranslation
    resource UniboV4.Events.EventStage
    resource UniboV4.Events.EventStageTranslation
  end
end
