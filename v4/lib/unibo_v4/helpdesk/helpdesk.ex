defmodule UniboV4.Helpdesk do
  use Ash.Domain

  resources do
    resource UniboV4.Helpdesk.HelpdeskTicket
    resource UniboV4.Helpdesk.HelpdeskTicketType
    resource UniboV4.Helpdesk.HelpdeskTeam
    resource UniboV4.Helpdesk.HelpdeskSLA
    resource UniboV4.Helpdesk.HelpdeskSLAStatus
    resource UniboV4.Helpdesk.FieldServiceOrder
    resource UniboV4.Helpdesk.FieldServiceAssignment
    resource UniboV4.Helpdesk.Appointment
    resource UniboV4.Helpdesk.User
    resource UniboV4.Helpdesk.Partner
    resource UniboV4.Helpdesk.Employee
    resource UniboV4.Helpdesk.Project
    resource UniboV4.Helpdesk.SalesOrder
    resource UniboV4.Helpdesk.Tag
    resource UniboV4.Helpdesk.HelpdeskTag
    resource UniboV4.Helpdesk.HelpdeskStage
    resource UniboV4.Helpdesk.TimesheetEntry
    resource UniboV4.Helpdesk.Rating
    resource UniboV4.Helpdesk.HelpdeskTicketTagLink
    resource UniboV4.Helpdesk.HelpdeskTeamMemberLink
    resource UniboV4.Helpdesk.HelpdeskTeamStageLink
    resource UniboV4.Helpdesk.HelpdeskSLATagLink
    resource UniboV4.Helpdesk.HelpdeskSLAPartnerLink
    resource UniboV4.Helpdesk.HelpdeskSLAExcludeStageLink
    resource UniboV4.Helpdesk.FieldServiceOrderTagLink
  end
end
