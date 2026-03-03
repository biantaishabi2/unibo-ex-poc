defmodule UniboV4.Calendar.Calendar do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Calendar.Calendar.Calendar
    resource UniboV4.Calendar.Calendar.CalendarTranslation
    resource UniboV4.Calendar.Calendar.CalendarEvent
    resource UniboV4.Calendar.Calendar.CalendarEventTranslation
    resource UniboV4.Calendar.Calendar.Attendee
    resource UniboV4.Calendar.Calendar.WorkSchedule
    resource UniboV4.Calendar.Calendar.WorkScheduleTranslation
    resource UniboV4.Calendar.Calendar.WeekTemplate
    resource UniboV4.Calendar.Calendar.WeekTemplateTranslation
    resource UniboV4.Calendar.Calendar.CalendarException
    resource UniboV4.Calendar.Calendar.CalendarExceptionTranslation
    resource UniboV4.Calendar.Calendar.WeekException
    resource UniboV4.Calendar.Calendar.WeekExceptionTranslation
  end
end
