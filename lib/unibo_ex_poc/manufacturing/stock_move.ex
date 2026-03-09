defmodule UniboExPoc.Manufacturing.StockMove do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "库存移动占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "manufacturing_stock_moves"
    repo UniboExPoc.Repo
  end

  graphql do
    type :manufacturing_stock_move

    queries do
      get :get_manufacturing_stock_move, :read
      list :list_manufacturing_stock_moves, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :quantity_done, :decimal, public?: true
    attribute :state, :string, public?: true
  end

  relationships do
    belongs_to :production, UniboExPoc.Manufacturing.ManufacturingOrder do
      public? true
    end
    belongs_to :raw_material_production, UniboExPoc.Manufacturing.ManufacturingOrder do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
