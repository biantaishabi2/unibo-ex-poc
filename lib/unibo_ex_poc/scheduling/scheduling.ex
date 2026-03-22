defmodule UniboExPoc.Scheduling do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Scheduling.Employee
    resource UniboExPoc.Scheduling.Department
    resource UniboExPoc.Scheduling.ShiftType
    resource UniboExPoc.Scheduling.ShiftType.Version
    resource UniboExPoc.Scheduling.SchedulingPeriod
    resource UniboExPoc.Scheduling.SchedulingPeriod.Version
    resource UniboExPoc.Scheduling.CoverageRequirement
    resource UniboExPoc.Scheduling.CoverageRequirement.Version
    resource UniboExPoc.Scheduling.ScheduleVersion
    resource UniboExPoc.Scheduling.ScheduleVersion.Version
    resource UniboExPoc.Scheduling.ShiftAssignment
    resource UniboExPoc.Scheduling.ShiftAssignment.Version
    resource UniboExPoc.Scheduling.SchedulingConstraint
    resource UniboExPoc.Scheduling.SchedulingConstraint.Version
    resource UniboExPoc.Scheduling.ShiftPreference
    resource UniboExPoc.Scheduling.ShiftPreference.Version
    resource UniboExPoc.Scheduling.MedicalStaffProfile
    resource UniboExPoc.Scheduling.MedicalStaffProfile.Version
    resource UniboExPoc.Scheduling.SolverRun
    resource UniboExPoc.Scheduling.SolverRun.Version
    resource UniboExPoc.Scheduling.ConstraintViolation
    resource UniboExPoc.Scheduling.ConstraintViolation.Version
  end
end
