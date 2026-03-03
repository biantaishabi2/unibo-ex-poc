defmodule UniboV4.Maintenance.SalesOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "maintenance_sales_orders"
    repo UniboV4.Repo
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
