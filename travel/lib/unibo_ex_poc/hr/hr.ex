defmodule UniboExPoc.HR do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.HR.Employee
    resource UniboExPoc.HR.Department
    resource UniboExPoc.HR.JobPosition
    resource UniboExPoc.HR.EmploymentContract
    resource UniboExPoc.HR.Attendance
    resource UniboExPoc.HR.WorkLocation
    resource UniboExPoc.HR.EmployeeLocation
    resource UniboExPoc.HR.JourneyTemplate
    resource UniboExPoc.HR.JourneyStep
    resource UniboExPoc.HR.EmployeeJourney
    resource UniboExPoc.HR.EmployeeCategory
    resource UniboExPoc.HR.EmployeeCategoryLink
    resource UniboExPoc.HR.DepartureReason
    resource UniboExPoc.HR.ContractType
    resource UniboExPoc.HR.AttendanceOvertime
    resource UniboExPoc.HR.Expense
    resource UniboExPoc.HR.ExpenseSheet
    resource UniboExPoc.HR.BankAccount
    resource UniboExPoc.HR.Dependent
    resource UniboExPoc.HR.Job
    resource UniboExPoc.HR.EmployeeGroup
    resource UniboExPoc.HR.EmployeeSubgroup
    resource UniboExPoc.HR.PersonnelAction
    resource UniboExPoc.HR.Party
  end
end
