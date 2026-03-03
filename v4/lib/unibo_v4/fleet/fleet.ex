defmodule UniboV4.Fleet.Fleet do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Fleet.Fleet.FleetVehicle
    resource UniboV4.Fleet.Fleet.FleetVehicleType
    resource UniboV4.Fleet.Fleet.FleetVehicleTypeTranslation
    resource UniboV4.Fleet.Fleet.Driver
    resource UniboV4.Fleet.Fleet.VehicleAssignment
    resource UniboV4.Fleet.Fleet.VehicleService
    resource UniboV4.Fleet.Fleet.VehicleContract
    resource UniboV4.Fleet.Fleet.HrEmployee
  end
end
