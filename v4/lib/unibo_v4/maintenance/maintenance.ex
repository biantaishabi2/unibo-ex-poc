defmodule UniboV4.Maintenance do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Maintenance.Equipment
    resource UniboV4.Maintenance.Vehicle
    resource UniboV4.Maintenance.MaintenanceRequest
    resource UniboV4.Maintenance.MaintenanceSchedule
    resource UniboV4.Maintenance.RepairOrder
  end
end
