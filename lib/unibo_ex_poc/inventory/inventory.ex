defmodule UniboV4.Inventory do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Inventory.Warehouse
    resource UniboV4.Inventory.Warehouse.Version
    resource UniboV4.Inventory.StockLocation
    resource UniboV4.Inventory.StockLocation.Version
    resource UniboV4.Inventory.StockPicking
    resource UniboV4.Inventory.StockPicking.Version
    resource UniboV4.Inventory.StockMove
    resource UniboV4.Inventory.StockMove.Version
    resource UniboV4.Inventory.StockMoveLine
    resource UniboV4.Inventory.StockMoveLine.Version
    resource UniboV4.Inventory.StockQuant
    resource UniboV4.Inventory.StockQuant.Version
    resource UniboV4.Inventory.StockPickingItem
    resource UniboV4.Inventory.StockPickingItem.Version
    resource UniboV4.Inventory.Lot
    resource UniboV4.Inventory.Lot.Version
    resource UniboV4.Inventory.PickingBatch
    resource UniboV4.Inventory.PickingBatch.Version
    resource UniboV4.Inventory.LandedCost
    resource UniboV4.Inventory.LandedCost.Version
    resource UniboV4.Inventory.LandedCostLine
    resource UniboV4.Inventory.LandedCostLine.Version
    resource UniboV4.Inventory.ValuationAdjustmentLine
    resource UniboV4.Inventory.LandedCostPicking
    resource UniboV4.Inventory.StockMoveDependencyLink
    resource UniboV4.Inventory.RemovalStrategy
    resource UniboV4.Inventory.Party
  end
end
