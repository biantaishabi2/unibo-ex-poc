defmodule UniboV4.HR do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.HR.Employee
    resource UniboV4.HR.Employee.Version
    resource UniboV4.HR.Department
    resource UniboV4.HR.Department.Version
    resource UniboV4.HR.JobPosition
    resource UniboV4.HR.JobPosition.Version
    resource UniboV4.HR.EmploymentContract
    resource UniboV4.HR.EmploymentContract.Version
    resource UniboV4.HR.LeaveType
    resource UniboV4.HR.LeaveType.Version
    resource UniboV4.HR.LeaveRequest
    resource UniboV4.HR.LeaveRequest.Version
    resource UniboV4.HR.Attendance
    resource UniboV4.HR.Attendance.Version
    resource UniboV4.HR.PaySlip
    resource UniboV4.HR.PaySlip.Version
    resource UniboV4.HR.PayGrade
    resource UniboV4.HR.PayGrade.Version
    resource UniboV4.HR.PerformanceReview
    resource UniboV4.HR.PerformanceReview.Version
    resource UniboV4.HR.JobRequisition
    resource UniboV4.HR.JobRequisition.Version
    resource UniboV4.HR.JobApplication
    resource UniboV4.HR.JobApplication.Version
    resource UniboV4.HR.Skill
    resource UniboV4.HR.Skill.Version
    resource UniboV4.HR.SkillType
    resource UniboV4.HR.SkillType.Version
    resource UniboV4.HR.SkillLevel
    resource UniboV4.HR.SkillLevel.Version
    resource UniboV4.HR.EmployeeSkill
    resource UniboV4.HR.EmployeeSkill.Version
    resource UniboV4.HR.Training
    resource UniboV4.HR.Training.Version
    resource UniboV4.HR.JobApplicationInterviewerLink
    resource UniboV4.HR.EmployeeSkillLog
    resource UniboV4.HR.ResumeLineType
    resource UniboV4.HR.ResumeLineType.Version
    resource UniboV4.HR.ResumeLine
    resource UniboV4.HR.ResumeLine.Version
    resource UniboV4.HR.WorkEntryType
    resource UniboV4.HR.WorkEntryType.Version
    resource UniboV4.HR.WorkEntry
    resource UniboV4.HR.WorkEntry.Version
    resource UniboV4.HR.WorkLocation
    resource UniboV4.HR.WorkLocation.Version
    resource UniboV4.HR.EmployeeLocation
    resource UniboV4.HR.EmployeeLocation.Version
    resource UniboV4.HR.ApplicantSkill
    resource UniboV4.HR.ApplicantSkill.Version
    resource UniboV4.HR.Party
  end
end
