defmodule UniboV4.Maintenance.StockMove do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "maintenance_stock_moves"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :repair_order, UniboV4.Maintenance.RepairOrder do
      public? true
    end
  end

  actions do
    defaults [:read]
  end

end
