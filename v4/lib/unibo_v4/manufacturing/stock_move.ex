defmodule UniboV4.Manufacturing.StockMove do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "manufacturing_stock_moves"
    repo UniboV4.Repo
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
    belongs_to :production, UniboV4.Manufacturing.ManufacturingOrder do
      public? true
    end
    belongs_to :raw_material_production, UniboV4.Manufacturing.ManufacturingOrder do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
