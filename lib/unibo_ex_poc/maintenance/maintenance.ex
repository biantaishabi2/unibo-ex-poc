defmodule UniboExPoc.Maintenance do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Maintenance.Equipment
    resource UniboExPoc.Maintenance.Equipment.Version
    resource UniboExPoc.Maintenance.EquipmentCategory
    resource UniboExPoc.Maintenance.EquipmentCategory.Version
    resource UniboExPoc.Maintenance.MaintenanceStage
    resource UniboExPoc.Maintenance.MaintenanceStage.Version
    resource UniboExPoc.Maintenance.MaintenanceRequest
    resource UniboExPoc.Maintenance.MaintenanceRequest.Version
    resource UniboExPoc.Maintenance.MaintenanceTeam
    resource UniboExPoc.Maintenance.MaintenanceTeam.Version
    resource UniboExPoc.Maintenance.MaintenanceSchedule
    resource UniboExPoc.Maintenance.MaintenanceSchedule.Version
    resource UniboExPoc.Maintenance.RepairOrder
    resource UniboExPoc.Maintenance.RepairOrder.Version
    resource UniboExPoc.Maintenance.VehicleModel
    resource UniboExPoc.Maintenance.VehicleModel.Version
    resource UniboExPoc.Maintenance.Vehicle
    resource UniboExPoc.Maintenance.Vehicle.Version
    resource UniboExPoc.Maintenance.VehicleState
    resource UniboExPoc.Maintenance.VehicleState.Version
    resource UniboExPoc.Maintenance.ServiceLog
    resource UniboExPoc.Maintenance.ServiceLog.Version
    resource UniboExPoc.Maintenance.Contract
    resource UniboExPoc.Maintenance.Contract.Version
    resource UniboExPoc.Maintenance.Odometer
    resource UniboExPoc.Maintenance.AssignmentLog
    resource UniboExPoc.Maintenance.ServiceType
    resource UniboExPoc.Maintenance.ServiceType.Version
    resource UniboExPoc.Maintenance.Product
    resource UniboExPoc.Maintenance.SalesOrder
    resource UniboExPoc.Maintenance.StockLocation
    resource UniboExPoc.Maintenance.Lot
    resource UniboExPoc.Maintenance.StockPicking
    resource UniboExPoc.Maintenance.StockMove
    resource UniboExPoc.Maintenance.RepairOrderLine
    resource UniboExPoc.Maintenance.VehicleTag
    resource UniboExPoc.Maintenance.VehicleModelBrand
    resource UniboExPoc.Maintenance.VehicleModelCategory
    resource UniboExPoc.Maintenance.MaintenanceTeamMemberLink
    resource UniboExPoc.Maintenance.VehicleTagLink
    resource UniboExPoc.Maintenance.ContractServiceItemLink
    resource UniboExPoc.Maintenance.Party
  end
end
