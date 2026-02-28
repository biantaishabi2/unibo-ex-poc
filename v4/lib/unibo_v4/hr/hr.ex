defmodule UniboV4.HR do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.HR.Employee
    resource UniboV4.HR.Department
    resource UniboV4.HR.JobPosition
    resource UniboV4.HR.EmploymentContract
    resource UniboV4.HR.LeaveRequest
    resource UniboV4.HR.LeaveType
    resource UniboV4.HR.Attendance
    resource UniboV4.HR.PaySlip
    resource UniboV4.HR.PayGrade
    resource UniboV4.HR.PerformanceReview
    resource UniboV4.HR.JobRequisition
    resource UniboV4.HR.JobApplication
    resource UniboV4.HR.Skill
    resource UniboV4.HR.Training
  end
end
