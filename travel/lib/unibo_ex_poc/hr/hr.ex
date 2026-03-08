defmodule UniboExPoc.HR do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.HR.Employee
    resource UniboExPoc.HR.Employee.Version
    resource UniboExPoc.HR.Department
    resource UniboExPoc.HR.Department.Version
    resource UniboExPoc.HR.JobPosition
    resource UniboExPoc.HR.JobPosition.Version
    resource UniboExPoc.HR.EmploymentContract
    resource UniboExPoc.HR.EmploymentContract.Version
    resource UniboExPoc.HR.LeaveType
    resource UniboExPoc.HR.LeaveType.Version
    resource UniboExPoc.HR.LeaveRequest
    resource UniboExPoc.HR.LeaveRequest.Version
    resource UniboExPoc.HR.Attendance
    resource UniboExPoc.HR.Attendance.Version
    resource UniboExPoc.HR.PaySlip
    resource UniboExPoc.HR.PaySlip.Version
    resource UniboExPoc.HR.PayGrade
    resource UniboExPoc.HR.PayGrade.Version
    resource UniboExPoc.HR.PerformanceReview
    resource UniboExPoc.HR.PerformanceReview.Version
    resource UniboExPoc.HR.JobRequisition
    resource UniboExPoc.HR.JobRequisition.Version
    resource UniboExPoc.HR.JobApplication
    resource UniboExPoc.HR.JobApplication.Version
    resource UniboExPoc.HR.Skill
    resource UniboExPoc.HR.Skill.Version
    resource UniboExPoc.HR.SkillType
    resource UniboExPoc.HR.SkillType.Version
    resource UniboExPoc.HR.SkillLevel
    resource UniboExPoc.HR.SkillLevel.Version
    resource UniboExPoc.HR.EmployeeSkill
    resource UniboExPoc.HR.EmployeeSkill.Version
    resource UniboExPoc.HR.Training
    resource UniboExPoc.HR.Training.Version
    resource UniboExPoc.HR.JobApplicationInterviewerLink
    resource UniboExPoc.HR.EmployeeSkillLog
    resource UniboExPoc.HR.ResumeLineType
    resource UniboExPoc.HR.ResumeLineType.Version
    resource UniboExPoc.HR.ResumeLine
    resource UniboExPoc.HR.ResumeLine.Version
    resource UniboExPoc.HR.WorkEntryType
    resource UniboExPoc.HR.WorkEntryType.Version
    resource UniboExPoc.HR.WorkEntry
    resource UniboExPoc.HR.WorkEntry.Version
    resource UniboExPoc.HR.WorkLocation
    resource UniboExPoc.HR.WorkLocation.Version
    resource UniboExPoc.HR.EmployeeLocation
    resource UniboExPoc.HR.EmployeeLocation.Version
    resource UniboExPoc.HR.ApplicantSkill
    resource UniboExPoc.HR.ApplicantSkill.Version
    resource UniboExPoc.HR.Party
  end
end
