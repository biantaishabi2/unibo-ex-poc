defmodule HospitalScheduling.Scheduling do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize?(false)
  end

  resources do
    resource(HospitalScheduling.Scheduling.Employee)
    resource(HospitalScheduling.Scheduling.Department)
    resource(HospitalScheduling.Scheduling.ShiftType)
    resource(HospitalScheduling.Scheduling.ShiftType.Version)
    resource(HospitalScheduling.Scheduling.SchedulingPeriod)
    resource(HospitalScheduling.Scheduling.SchedulingPeriod.Version)
    resource(HospitalScheduling.Scheduling.CoverageRequirement)
    resource(HospitalScheduling.Scheduling.CoverageRequirement.Version)
    resource(HospitalScheduling.Scheduling.ScheduleVersion)
    resource(HospitalScheduling.Scheduling.ScheduleVersion.Version)
    resource(HospitalScheduling.Scheduling.ShiftAssignment)
    resource(HospitalScheduling.Scheduling.ShiftAssignment.Version)
    resource(HospitalScheduling.Scheduling.SchedulingConstraint)
    resource(HospitalScheduling.Scheduling.SchedulingConstraint.Version)
    resource(HospitalScheduling.Scheduling.ShiftPreference)
    resource(HospitalScheduling.Scheduling.ShiftPreference.Version)
    resource(HospitalScheduling.Scheduling.MedicalStaffProfile)
    resource(HospitalScheduling.Scheduling.MedicalStaffProfile.Version)
    resource(HospitalScheduling.Scheduling.SolverRun)
    resource(HospitalScheduling.Scheduling.SolverRun.Version)
    resource(HospitalScheduling.Scheduling.ConstraintViolation)
    resource(HospitalScheduling.Scheduling.ConstraintViolation.Version)
  end
end
