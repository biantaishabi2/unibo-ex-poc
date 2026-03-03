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
    resource UniboV4.HR.LeaveType
    resource UniboV4.HR.LeaveRequest
    resource UniboV4.HR.Attendance
    resource UniboV4.HR.PaySlip
    resource UniboV4.HR.PayGrade
    resource UniboV4.HR.PerformanceReview
    resource UniboV4.HR.JobRequisition
    resource UniboV4.HR.JobApplication
    resource UniboV4.HR.Skill
    resource UniboV4.HR.SkillType
    resource UniboV4.HR.SkillLevel
    resource UniboV4.HR.EmployeeSkill
    resource UniboV4.HR.Training
    resource UniboV4.HR.JobApplicationInterviewerLink
    resource UniboV4.HR.EmployeeSkillLog
    resource UniboV4.HR.ResumeLineType
    resource UniboV4.HR.ResumeLine
    resource UniboV4.HR.WorkEntryType
    resource UniboV4.HR.WorkEntry
    resource UniboV4.HR.WorkLocation
    resource UniboV4.HR.EmployeeLocation
    resource UniboV4.HR.ApplicantSkill
  end
end
