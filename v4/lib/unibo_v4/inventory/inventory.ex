defmodule UniboV4.Inventory do
  use Ash.Domain

  resources do
    resource UniboV4.Inventory.Warehouse
    resource UniboV4.Inventory.StockLocation
    resource UniboV4.Inventory.StockPicking
    resource UniboV4.Inventory.StockMove
    resource UniboV4.Inventory.StockMoveLine
    resource UniboV4.Inventory.StockQuant
    resource UniboV4.Inventory.StockPickingItem
    resource UniboV4.Inventory.Lot
    resource UniboV4.Inventory.PickingBatch
    resource UniboV4.Inventory.LandedCost
    resource UniboV4.Inventory.LandedCostLine
    resource UniboV4.Inventory.ValuationAdjustmentLine
    resource UniboV4.Inventory.LandedCostPicking
    resource UniboV4.Inventory.StockMoveDependencyLink
    resource UniboV4.Inventory.Partner
    resource UniboV4.Inventory.RemovalStrategy
  end
end
