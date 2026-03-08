defmodule UniboExPoc.Fleet do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Fleet.FleetVehicle
    resource UniboExPoc.Fleet.FleetVehicle.Version
    resource UniboExPoc.Fleet.FleetVehicleType
    resource UniboExPoc.Fleet.FleetVehicleTypeTranslation
    resource UniboExPoc.Fleet.FleetVehicleType.Version
    resource UniboExPoc.Fleet.Driver
    resource UniboExPoc.Fleet.Driver.Version
    resource UniboExPoc.Fleet.VehicleAssignment
    resource UniboExPoc.Fleet.VehicleAssignment.Version
    resource UniboExPoc.Fleet.VehicleService
    resource UniboExPoc.Fleet.VehicleService.Version
    resource UniboExPoc.Fleet.VehicleContract
    resource UniboExPoc.Fleet.VehicleContract.Version
    resource UniboExPoc.Fleet.HrEmployee
    resource UniboExPoc.Fleet.Party
  end
end
