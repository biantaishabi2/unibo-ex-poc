defmodule UniboV4.Helpdesk.SalesOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_sales_orders"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :order_number, :string, public?: true
  end

  actions do
    defaults [:read]
  end

end
