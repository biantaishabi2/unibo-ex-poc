defmodule UniboV4.Maintenance.StockMove do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "maintenance_stock_moves"
    repo UniboV4.Repo
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
    attribute :repair_order_id, :uuid, public?: true
  end

  relationships do
    belongs_to :repair_order, UniboV4.Maintenance.RepairOrder do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
