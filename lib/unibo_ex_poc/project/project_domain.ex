defmodule UniboV4.Project do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Project.Project
    resource UniboV4.Project.Project.Version
    resource UniboV4.Project.Task
    resource UniboV4.Project.Task.Version
    resource UniboV4.Project.Milestone
    resource UniboV4.Project.Milestone.Version
    resource UniboV4.Project.TaskAssignment
    resource UniboV4.Project.TaskAssignment.Version
    resource UniboV4.Project.TaskDependency
    resource UniboV4.Project.TaskDependency.Version
    resource UniboV4.Project.Timesheet
    resource UniboV4.Project.Timesheet.Version
    resource UniboV4.Project.TimesheetEntry
    resource UniboV4.Project.TimesheetEntry.Version
    resource UniboV4.Project.PlanningSlot
    resource UniboV4.Project.PlanningSlot.Version
    resource UniboV4.Project.ProjectTaskStageLink
    resource UniboV4.Project.Employee
    resource UniboV4.Project.TaskStage
    resource UniboV4.Project.PlanningRecurrence
    resource UniboV4.Project.PlanningRole
    resource UniboV4.Project.PlanningSlotTemplate
    resource UniboV4.Project.ProjectStage
    resource UniboV4.Project.TaskRecurrence
    resource UniboV4.Project.AnalyticAccount
    resource UniboV4.Project.ResourceCalendar
    resource UniboV4.Project.Party
  end
end
