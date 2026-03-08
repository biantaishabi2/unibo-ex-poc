defmodule UniboExPoc.Maintenance.StockMove do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "库存移动占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "maintenance_stock_moves"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_stock_move

    queries do
      get :get_maintenance_stock_move, :read
      list :list_maintenance_stock_moves, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :repair_order, UniboExPoc.Maintenance.RepairOrder do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
