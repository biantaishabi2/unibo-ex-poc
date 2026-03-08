defmodule UniboV4.Fleet do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Fleet.FleetVehicle
    resource UniboV4.Fleet.FleetVehicle.Version
    resource UniboV4.Fleet.FleetVehicleType
    resource UniboV4.Fleet.FleetVehicleTypeTranslation
    resource UniboV4.Fleet.FleetVehicleType.Version
    resource UniboV4.Fleet.Driver
    resource UniboV4.Fleet.Driver.Version
    resource UniboV4.Fleet.VehicleAssignment
    resource UniboV4.Fleet.VehicleAssignment.Version
    resource UniboV4.Fleet.VehicleService
    resource UniboV4.Fleet.VehicleService.Version
    resource UniboV4.Fleet.VehicleContract
    resource UniboV4.Fleet.VehicleContract.Version
    resource UniboV4.Fleet.HrEmployee
    resource UniboV4.Fleet.Party
  end
end
