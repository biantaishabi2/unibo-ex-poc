defmodule UniboV4.Manufacturing do
  use Ash.Domain

  resources do
    resource UniboV4.Manufacturing.BillOfMaterials
    resource UniboV4.Manufacturing.BomLine
    resource UniboV4.Manufacturing.BomByproduct
    resource UniboV4.Manufacturing.ManufacturingOrder
    resource UniboV4.Manufacturing.WorkOrder
    resource UniboV4.Manufacturing.WorkCenter
    resource UniboV4.Manufacturing.WorkcenterProductivity
    resource UniboV4.Manufacturing.RoutingOperation
    resource UniboV4.Manufacturing.StockMove
    resource UniboV4.Manufacturing.StockPicking
    resource UniboV4.Manufacturing.StockScrap
    resource UniboV4.Manufacturing.WorkOrderDependencyLink
    resource UniboV4.Manufacturing.MrpSchedule
  end
end
