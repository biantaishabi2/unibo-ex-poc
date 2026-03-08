defmodule UniboExPoc.Manufacturing do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Manufacturing.BillOfMaterials
    resource UniboExPoc.Manufacturing.BillOfMaterials.Version
    resource UniboExPoc.Manufacturing.BomLine
    resource UniboExPoc.Manufacturing.BomLine.Version
    resource UniboExPoc.Manufacturing.BomByproduct
    resource UniboExPoc.Manufacturing.BomByproduct.Version
    resource UniboExPoc.Manufacturing.ManufacturingOrder
    resource UniboExPoc.Manufacturing.ManufacturingOrder.Version
    resource UniboExPoc.Manufacturing.WorkOrder
    resource UniboExPoc.Manufacturing.WorkOrder.Version
    resource UniboExPoc.Manufacturing.WorkCenter
    resource UniboExPoc.Manufacturing.WorkCenter.Version
    resource UniboExPoc.Manufacturing.WorkcenterProductivity
    resource UniboExPoc.Manufacturing.WorkcenterProductivity.Version
    resource UniboExPoc.Manufacturing.RoutingOperation
    resource UniboExPoc.Manufacturing.RoutingOperation.Version
    resource UniboExPoc.Manufacturing.StockMove
    resource UniboExPoc.Manufacturing.StockPicking
    resource UniboExPoc.Manufacturing.StockScrap
    resource UniboExPoc.Manufacturing.WorkOrderDependencyLink
    resource UniboExPoc.Manufacturing.MrpSchedule
  end
end
