# Workflow: order_item_editing — 旧版订单行编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Purchasing.PurchaseOrderItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "purchasing_purchase_order_items"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_code, :string, public?: true
    attribute :quantity, :integer do
      allow_nil? false
      public? true
    end
    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :line_amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :received_quantity, :integer do
      default 0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :order, UniboV4.Purchasing.PurchaseOrder do
      public? true
      allow_nil? false
    end
  end

  actions do
    create :create do
      primary? true
      accept [:product_name, :product_code, :quantity, :unit_price]
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)

        if quantity && unit_price do
          Ash.Changeset.force_change_attribute(changeset, :line_amount, Decimal.mult(quantity, unit_price))
        else
          changeset
        end
      end
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:quantity, :unit_price]
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        unit_price = Ash.Changeset.get_attribute(changeset, :unit_price)

        if quantity && unit_price do
          Ash.Changeset.force_change_attribute(changeset, :line_amount, Decimal.mult(quantity, unit_price))
        else
          changeset
        end
      end
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

  validations do
    validate compare(:quantity, greater_than: 0)
    validate compare(:unit_price, greater_than_or_equal_to: 0)
  end

end
