defmodule UniboExPoc.Helpdesk.SalesOrder do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "销售订单占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "helpdesk_sales_orders"
    repo UniboExPoc.Repo
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
