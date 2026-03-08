defmodule UniboV4.Calendar do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Calendar.Calendar
    resource UniboV4.Calendar.CalendarTranslation
    resource UniboV4.Calendar.Calendar.Version
    resource UniboV4.Calendar.CalendarEvent
    resource UniboV4.Calendar.CalendarEventTranslation
    resource UniboV4.Calendar.CalendarEvent.Version
    resource UniboV4.Calendar.Attendee
    resource UniboV4.Calendar.Attendee.Version
    resource UniboV4.Calendar.WorkSchedule
    resource UniboV4.Calendar.WorkScheduleTranslation
    resource UniboV4.Calendar.WorkSchedule.Version
    resource UniboV4.Calendar.WeekTemplate
    resource UniboV4.Calendar.WeekTemplateTranslation
    resource UniboV4.Calendar.WeekTemplate.Version
    resource UniboV4.Calendar.CalendarException
    resource UniboV4.Calendar.CalendarExceptionTranslation
    resource UniboV4.Calendar.CalendarException.Version
    resource UniboV4.Calendar.WeekException
    resource UniboV4.Calendar.WeekExceptionTranslation
    resource UniboV4.Calendar.WeekException.Version
    resource UniboV4.Calendar.Party
  end
end
