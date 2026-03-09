defmodule UniboExPoc.Maintenance.SalesOrder do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "销售订单占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "maintenance_sales_orders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_sales_order

    queries do
      get :get_maintenance_sales_order, :read
      list :list_maintenance_sales_orders, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :order_number, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
