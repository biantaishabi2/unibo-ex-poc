defmodule UniboExPoc.Project do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Project.Project
    resource UniboExPoc.Project.Project.Version
    resource UniboExPoc.Project.Task
    resource UniboExPoc.Project.Task.Version
    resource UniboExPoc.Project.Milestone
    resource UniboExPoc.Project.Milestone.Version
    resource UniboExPoc.Project.TaskAssignment
    resource UniboExPoc.Project.TaskAssignment.Version
    resource UniboExPoc.Project.TaskDependency
    resource UniboExPoc.Project.TaskDependency.Version
    resource UniboExPoc.Project.Timesheet
    resource UniboExPoc.Project.Timesheet.Version
    resource UniboExPoc.Project.TimesheetEntry
    resource UniboExPoc.Project.TimesheetEntry.Version
    resource UniboExPoc.Project.PlanningSlot
    resource UniboExPoc.Project.PlanningSlot.Version
    resource UniboExPoc.Project.ProjectTaskStageLink
    resource UniboExPoc.Project.Employee
    resource UniboExPoc.Project.TaskStage
    resource UniboExPoc.Project.PlanningRecurrence
    resource UniboExPoc.Project.PlanningRole
    resource UniboExPoc.Project.PlanningSlotTemplate
    resource UniboExPoc.Project.ProjectStage
    resource UniboExPoc.Project.TaskRecurrence
    resource UniboExPoc.Project.AnalyticAccount
    resource UniboExPoc.Project.ResourceCalendar
    resource UniboExPoc.Project.Party
  end
end
