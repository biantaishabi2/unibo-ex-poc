defmodule UniboExPoc.Maintenance.StockPicking do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "拣货单占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "maintenance_stock_pickings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_stock_picking

    queries do
      get :get_maintenance_stock_picking, :read
      list :list_maintenance_stock_pickings, :read
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
