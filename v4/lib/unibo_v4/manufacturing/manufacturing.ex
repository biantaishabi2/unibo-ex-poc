defmodule UniboV4.Manufacturing do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Manufacturing.BillOfMaterials
    resource UniboV4.Manufacturing.BomLine
    resource UniboV4.Manufacturing.ManufacturingOrder
    resource UniboV4.Manufacturing.WorkOrder
    resource UniboV4.Manufacturing.WorkCenter
    resource UniboV4.Manufacturing.RoutingOperation
    resource UniboV4.Manufacturing.MrpSchedule
  end
end
