defmodule UniboV4.Maintenance do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Maintenance.Equipment
    resource UniboV4.Maintenance.Equipment.Version
    resource UniboV4.Maintenance.EquipmentCategory
    resource UniboV4.Maintenance.EquipmentCategory.Version
    resource UniboV4.Maintenance.MaintenanceStage
    resource UniboV4.Maintenance.MaintenanceStage.Version
    resource UniboV4.Maintenance.MaintenanceRequest
    resource UniboV4.Maintenance.MaintenanceRequest.Version
    resource UniboV4.Maintenance.MaintenanceTeam
    resource UniboV4.Maintenance.MaintenanceTeam.Version
    resource UniboV4.Maintenance.MaintenanceSchedule
    resource UniboV4.Maintenance.MaintenanceSchedule.Version
    resource UniboV4.Maintenance.RepairOrder
    resource UniboV4.Maintenance.RepairOrder.Version
    resource UniboV4.Maintenance.VehicleModel
    resource UniboV4.Maintenance.VehicleModel.Version
    resource UniboV4.Maintenance.Vehicle
    resource UniboV4.Maintenance.Vehicle.Version
    resource UniboV4.Maintenance.VehicleState
    resource UniboV4.Maintenance.VehicleState.Version
    resource UniboV4.Maintenance.ServiceLog
    resource UniboV4.Maintenance.ServiceLog.Version
    resource UniboV4.Maintenance.Contract
    resource UniboV4.Maintenance.Contract.Version
    resource UniboV4.Maintenance.Odometer
    resource UniboV4.Maintenance.AssignmentLog
    resource UniboV4.Maintenance.ServiceType
    resource UniboV4.Maintenance.ServiceType.Version
    resource UniboV4.Maintenance.Product
    resource UniboV4.Maintenance.SalesOrder
    resource UniboV4.Maintenance.StockLocation
    resource UniboV4.Maintenance.Lot
    resource UniboV4.Maintenance.StockPicking
    resource UniboV4.Maintenance.StockMove
    resource UniboV4.Maintenance.RepairOrderLine
    resource UniboV4.Maintenance.VehicleTag
    resource UniboV4.Maintenance.VehicleModelBrand
    resource UniboV4.Maintenance.VehicleModelCategory
    resource UniboV4.Maintenance.MaintenanceTeamMemberLink
    resource UniboV4.Maintenance.VehicleTagLink
    resource UniboV4.Maintenance.ContractServiceItemLink
    resource UniboV4.Maintenance.Party
  end
end
