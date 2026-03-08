defmodule UniboV4.Helpdesk do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Helpdesk.HelpdeskTicket
    resource UniboV4.Helpdesk.HelpdeskTicket.Version
    resource UniboV4.Helpdesk.HelpdeskTicketType
    resource UniboV4.Helpdesk.HelpdeskTicketType.Version
    resource UniboV4.Helpdesk.HelpdeskTeam
    resource UniboV4.Helpdesk.HelpdeskTeam.Version
    resource UniboV4.Helpdesk.HelpdeskSLA
    resource UniboV4.Helpdesk.HelpdeskSLA.Version
    resource UniboV4.Helpdesk.HelpdeskSLAStatus
    resource UniboV4.Helpdesk.HelpdeskSLAStatus.Version
    resource UniboV4.Helpdesk.FieldServiceOrder
    resource UniboV4.Helpdesk.FieldServiceOrder.Version
    resource UniboV4.Helpdesk.FieldServiceAssignment
    resource UniboV4.Helpdesk.FieldServiceAssignment.Version
    resource UniboV4.Helpdesk.FsmTaskStage
    resource UniboV4.Helpdesk.FsmTaskStage.Version
    resource UniboV4.Helpdesk.WorksheetTemplate
    resource UniboV4.Helpdesk.WorksheetTemplate.Version
    resource UniboV4.Helpdesk.Worksheet
    resource UniboV4.Helpdesk.Worksheet.Version
    resource UniboV4.Helpdesk.FsmMaterialLine
    resource UniboV4.Helpdesk.FsmMaterialLine.Version
    resource UniboV4.Helpdesk.FsmTimesheetEntry
    resource UniboV4.Helpdesk.FsmTimesheetEntry.Version
    resource UniboV4.Helpdesk.Product
    resource UniboV4.Helpdesk.Appointment
    resource UniboV4.Helpdesk.Appointment.Version
    resource UniboV4.Helpdesk.Employee
    resource UniboV4.Helpdesk.Project
    resource UniboV4.Helpdesk.SalesOrder
    resource UniboV4.Helpdesk.Tag
    resource UniboV4.Helpdesk.HelpdeskTag
    resource UniboV4.Helpdesk.HelpdeskStage
    resource UniboV4.Helpdesk.TimesheetEntry
    resource UniboV4.Helpdesk.Rating
    resource UniboV4.Helpdesk.Rating.Version
    resource UniboV4.Helpdesk.HelpdeskTicketTagLink
    resource UniboV4.Helpdesk.HelpdeskTeamMemberLink
    resource UniboV4.Helpdesk.HelpdeskTeamStageLink
    resource UniboV4.Helpdesk.HelpdeskSLATagLink
    resource UniboV4.Helpdesk.HelpdeskSLAPartnerLink
    resource UniboV4.Helpdesk.HelpdeskSLAExcludeStageLink
    resource UniboV4.Helpdesk.FieldServiceOrderTagLink
    resource UniboV4.Helpdesk.Party
  end
end
