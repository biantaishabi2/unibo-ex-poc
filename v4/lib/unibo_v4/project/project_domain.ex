defmodule UniboV4.Project do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Project.Project
    resource UniboV4.Project.Task
    resource UniboV4.Project.Milestone
    resource UniboV4.Project.TaskAssignment
    resource UniboV4.Project.TaskDependency
    resource UniboV4.Project.Timesheet
    resource UniboV4.Project.TimesheetEntry
  end
end
