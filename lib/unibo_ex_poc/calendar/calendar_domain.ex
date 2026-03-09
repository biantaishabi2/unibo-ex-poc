defmodule UniboExPoc.Calendar do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Calendar.Calendar
    resource UniboExPoc.Calendar.CalendarTranslation
    resource UniboExPoc.Calendar.Calendar.Version
    resource UniboExPoc.Calendar.CalendarEvent
    resource UniboExPoc.Calendar.CalendarEventTranslation
    resource UniboExPoc.Calendar.CalendarEvent.Version
    resource UniboExPoc.Calendar.Attendee
    resource UniboExPoc.Calendar.Attendee.Version
    resource UniboExPoc.Calendar.WorkSchedule
    resource UniboExPoc.Calendar.WorkScheduleTranslation
    resource UniboExPoc.Calendar.WorkSchedule.Version
    resource UniboExPoc.Calendar.WeekTemplate
    resource UniboExPoc.Calendar.WeekTemplateTranslation
    resource UniboExPoc.Calendar.WeekTemplate.Version
    resource UniboExPoc.Calendar.CalendarException
    resource UniboExPoc.Calendar.CalendarExceptionTranslation
    resource UniboExPoc.Calendar.CalendarException.Version
    resource UniboExPoc.Calendar.WeekException
    resource UniboExPoc.Calendar.WeekExceptionTranslation
    resource UniboExPoc.Calendar.WeekException.Version
    resource UniboExPoc.Calendar.Party
  end
end
