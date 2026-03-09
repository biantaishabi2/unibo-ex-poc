defmodule UniboExPoc.Inventory do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Inventory.Warehouse
    resource UniboExPoc.Inventory.Warehouse.Version
    resource UniboExPoc.Inventory.StockLocation
    resource UniboExPoc.Inventory.StockLocation.Version
    resource UniboExPoc.Inventory.StockPicking
    resource UniboExPoc.Inventory.StockPicking.Version
    resource UniboExPoc.Inventory.StockMove
    resource UniboExPoc.Inventory.StockMove.Version
    resource UniboExPoc.Inventory.StockMoveLine
    resource UniboExPoc.Inventory.StockMoveLine.Version
    resource UniboExPoc.Inventory.StockQuant
    resource UniboExPoc.Inventory.StockQuant.Version
    resource UniboExPoc.Inventory.StockPickingItem
    resource UniboExPoc.Inventory.StockPickingItem.Version
    resource UniboExPoc.Inventory.Lot
    resource UniboExPoc.Inventory.Lot.Version
    resource UniboExPoc.Inventory.PickingBatch
    resource UniboExPoc.Inventory.PickingBatch.Version
    resource UniboExPoc.Inventory.LandedCost
    resource UniboExPoc.Inventory.LandedCost.Version
    resource UniboExPoc.Inventory.LandedCostLine
    resource UniboExPoc.Inventory.LandedCostLine.Version
    resource UniboExPoc.Inventory.ValuationAdjustmentLine
    resource UniboExPoc.Inventory.LandedCostPicking
    resource UniboExPoc.Inventory.StockMoveDependencyLink
    resource UniboExPoc.Inventory.RemovalStrategy
    resource UniboExPoc.Inventory.Party
  end
end
