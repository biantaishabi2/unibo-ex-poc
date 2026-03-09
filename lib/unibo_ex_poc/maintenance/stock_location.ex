defmodule UniboExPoc.Maintenance.StockLocation do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "库位占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "maintenance_stock_locations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_stock_location

    queries do
      get :get_maintenance_stock_location, :read
      list :list_maintenance_stock_locations, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
