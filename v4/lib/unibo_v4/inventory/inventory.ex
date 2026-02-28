defmodule UniboV4.Inventory do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Inventory.Warehouse
    resource UniboV4.Inventory.StockLocation
    resource UniboV4.Inventory.StockMove
    resource UniboV4.Inventory.StockQuant
    resource UniboV4.Inventory.StockPicking
    resource UniboV4.Inventory.StockPickingItem
    resource UniboV4.Inventory.Lot
  end
end
