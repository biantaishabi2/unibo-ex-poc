defmodule UniboExPoc.Inventory.StockMoveDependencyLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "库存移动依赖关系桥接占位实体"
  end

  postgres do
    table "inventory_stock_move_dependency_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :inventory_stock_move_dependency_link

    queries do
      get :get_inventory_stock_move_dependency_link, :read
      list :list_inventory_stock_move_dependency_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :move_orig, UniboExPoc.Inventory.StockMove do
      public? true
      allow_nil? false
    end
    belongs_to :move_dest, UniboExPoc.Inventory.StockMove do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
