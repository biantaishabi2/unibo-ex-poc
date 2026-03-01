# Workflow: requisition_item_editing — 采购申请行编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Purchasing.PurchaseRequisitionItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "purchasing_purchase_requisition_items"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_purchase_requisition_item

    mutations do
      create :create_purchasing_purchase_requisition_item, :create
      update :update_purchasing_purchase_requisition_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_description_variants, :string, public?: true
    attribute :product_qty, :decimal do
      allow_nil? false
      public? true
    end
    attribute :price_unit, :decimal do
      default 0
      public? true
    end
    attribute :estimated_amount, :decimal, public?: true
    attribute :schedule_date, :date, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :qty_ordered
  end

  relationships do
    belongs_to :requisition, UniboV4.Purchasing.PurchaseRequisition do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboV4.Purchasing.Product do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :product_description_variants, :product_qty, :price_unit, :schedule_date, :description]
      argument :product_id, :uuid
      argument :requisition_id, :uuid, allow_nil?: false
      change manage_relationship(:requisition_id, :requisition, type: :append, on_lookup: :relate)
      change fn changeset, _context ->
        product_qty = Ash.Changeset.get_attribute(changeset, :product_qty)
        price_unit = Ash.Changeset.get_attribute(changeset, :price_unit)

        if product_qty && price_unit do
          Ash.Changeset.force_change_attribute(changeset, :estimated_amount, Decimal.mult(product_qty, price_unit))
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
      accept [:product_qty, :price_unit, :schedule_date, :description]
      change fn changeset, _context ->
        product_qty = Ash.Changeset.get_attribute(changeset, :product_qty)
        price_unit = Ash.Changeset.get_attribute(changeset, :price_unit)

        if product_qty && price_unit do
          Ash.Changeset.force_change_attribute(changeset, :estimated_amount, Decimal.mult(product_qty, price_unit))
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
    validate compare(:product_qty, greater_than: 0)
    validate compare(:price_unit, greater_than_or_equal_to: 0)
  end

end
