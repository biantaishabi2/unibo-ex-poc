defmodule UniboExPoc.Helpdesk do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Helpdesk.HelpdeskTicket
    resource UniboExPoc.Helpdesk.HelpdeskTicket.Version
    resource UniboExPoc.Helpdesk.HelpdeskTicketType
    resource UniboExPoc.Helpdesk.HelpdeskTicketType.Version
    resource UniboExPoc.Helpdesk.HelpdeskTeam
    resource UniboExPoc.Helpdesk.HelpdeskTeam.Version
    resource UniboExPoc.Helpdesk.HelpdeskSLA
    resource UniboExPoc.Helpdesk.HelpdeskSLA.Version
    resource UniboExPoc.Helpdesk.HelpdeskSLAStatus
    resource UniboExPoc.Helpdesk.HelpdeskSLAStatus.Version
    resource UniboExPoc.Helpdesk.FieldServiceOrder
    resource UniboExPoc.Helpdesk.FieldServiceOrder.Version
    resource UniboExPoc.Helpdesk.FieldServiceAssignment
    resource UniboExPoc.Helpdesk.FieldServiceAssignment.Version
    resource UniboExPoc.Helpdesk.FsmTaskStage
    resource UniboExPoc.Helpdesk.FsmTaskStage.Version
    resource UniboExPoc.Helpdesk.WorksheetTemplate
    resource UniboExPoc.Helpdesk.WorksheetTemplate.Version
    resource UniboExPoc.Helpdesk.Worksheet
    resource UniboExPoc.Helpdesk.Worksheet.Version
    resource UniboExPoc.Helpdesk.FsmMaterialLine
    resource UniboExPoc.Helpdesk.FsmMaterialLine.Version
    resource UniboExPoc.Helpdesk.FsmTimesheetEntry
    resource UniboExPoc.Helpdesk.FsmTimesheetEntry.Version
    resource UniboExPoc.Helpdesk.Product
    resource UniboExPoc.Helpdesk.Appointment
    resource UniboExPoc.Helpdesk.Appointment.Version
    resource UniboExPoc.Helpdesk.Employee
    resource UniboExPoc.Helpdesk.Project
    resource UniboExPoc.Helpdesk.SalesOrder
    resource UniboExPoc.Helpdesk.Tag
    resource UniboExPoc.Helpdesk.HelpdeskTag
    resource UniboExPoc.Helpdesk.HelpdeskStage
    resource UniboExPoc.Helpdesk.TimesheetEntry
    resource UniboExPoc.Helpdesk.Rating
    resource UniboExPoc.Helpdesk.Rating.Version
    resource UniboExPoc.Helpdesk.HelpdeskTicketTagLink
    resource UniboExPoc.Helpdesk.HelpdeskTeamMemberLink
    resource UniboExPoc.Helpdesk.HelpdeskTeamStageLink
    resource UniboExPoc.Helpdesk.HelpdeskSLATagLink
    resource UniboExPoc.Helpdesk.HelpdeskSLAPartnerLink
    resource UniboExPoc.Helpdesk.HelpdeskSLAExcludeStageLink
    resource UniboExPoc.Helpdesk.FieldServiceOrderTagLink
    resource UniboExPoc.Helpdesk.Party
  end
end
