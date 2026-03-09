defmodule UniboExPoc.Manufacturing.StockPicking do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "拣货单占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "manufacturing_stock_pickings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :manufacturing_stock_picking

    queries do
      get :get_manufacturing_stock_picking, :read
      list :list_manufacturing_stock_pickings, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :state, :string, public?: true
  end

  relationships do
    belongs_to :production, UniboExPoc.Manufacturing.ManufacturingOrder do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
