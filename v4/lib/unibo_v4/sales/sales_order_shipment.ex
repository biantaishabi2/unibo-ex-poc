# Workflow: shipment_lifecycle — 发货流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> ship
#   ship --> deliver
#   deliver --> [*] : delivered
# ```
defmodule UniboV4.Sales.SalesOrderShipment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Sales.SalesOrderShipment.Notifier]

  postgres do
    table "sales_order_shipments"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_number, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :shipped, :delivered, :cancelled]
      default :draft
      public? true
    end
    attribute :ship_date, :date, public?: true
    attribute :delivery_date, :date, public?: true
    attribute :carrier, :string, public?: true
    attribute :tracking_number, :string, public?: true
    attribute :shipping_address, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :sales_order, UniboV4.Sales.SalesOrder do
      public? true
      allow_nil? false
    end
    belongs_to :shipped_by, UniboV4.Sales.User do
      public? true
    end
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    read :list do
    end
    read :search do
    end
    read :get do
    end
    read :preview do
    end
    read :compute do
    end
    read :lookup do
    end
    update :ship do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发货"
      change set_attribute(:status, :shipped)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :deliver do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :shipped do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :shipped}))
        end
      end
      # message: "只有已发货状态可以标记送达"
      change set_attribute(:status, :delivered)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  identities do
    identity :unique_shipment_number, [:shipment_number]
  end

end
