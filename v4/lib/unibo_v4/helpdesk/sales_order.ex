defmodule UniboV4.Helpdesk.SalesOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "helpdesk_sales_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_sales_order

    queries do
      get :get_helpdesk_sales_order, :read
      list :list_helpdesk_sales_orders, :read
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
