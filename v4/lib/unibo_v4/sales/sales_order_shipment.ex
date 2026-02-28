defmodule UniboV4.Sales.SalesOrderShipment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Sales.SalesOrderShipment.Notifier]

  postgres do
    table "sales_order_shipments"
    repo UniboV4.Repo
  end

  graphql do
    type :sales_order_shipment

    queries do
      get :get_sales_order_shipment, :read
      list :list_sales_order_shipments, :read
    end

    mutations do
      create :create_sales_order_shipment, :create
      update :ship_sales_order_shipment, :ship
      update :deliver_sales_order_shipment, :deliver
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :shipped, :delivered, :cancelled]
      default :draft
    end
    attribute :ship_date, :date
    attribute :delivery_date, :date
    attribute :carrier, :string
    attribute :tracking_number, :string
    attribute :shipping_address, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :sales_order, UniboV4.Sales.SalesOrder do
      allow_nil? false
    end
    belongs_to :shipped_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:shipment_number, :ship_date, :carrier, :tracking_number, :shipping_address, :notes]
      argument :sales_order_id, :uuid, allow_nil?: false
      change manage_relationship(:sales_order_id, :sales_order, type: :append, on_lookup: :relate)
      validate present(:shipment_number)
      change relate_actor(:shipped_by)
    end
    update :ship do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以发货"
      end
      change set_attribute(:status, :shipped)
    end
    update :deliver do
      accept []
      validate attribute_equals(:status, :shipped) do
        message "只有已发货状态可以标记送达"
      end
      change set_attribute(:status, :delivered)
    end
  end

  identities do
    identity :unique_shipment_number, [:shipment_number]
  end

end
