defmodule UniboV4.Manufacturing.StockScrap do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "manufacturing_stock_scraps"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :state, :string, public?: true
  end

  relationships do
    belongs_to :production, UniboV4.Manufacturing.ManufacturingOrder do
      public? true
    end
  end

  actions do
    defaults [:read]
  end

end
