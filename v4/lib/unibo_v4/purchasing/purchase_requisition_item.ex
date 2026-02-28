defmodule UniboV4.Purchasing.PurchaseRequisitionItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "purchase_requisition_items"
    repo UniboV4.Repo
  end

  graphql do
    type :purchase_requisition_item

    mutations do
      create :create_purchase_requisition_item, :create
      update :update_purchase_requisition_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string, allow_nil?: false
    attribute :quantity, :integer, allow_nil?: false
    attribute :estimated_unit_price, :decimal
    attribute :estimated_amount, :decimal
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :requisition, UniboV4.Purchasing.PurchaseRequisition do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :quantity, :estimated_unit_price, :description]
      argument :requisition_id, :uuid, allow_nil?: false
      change manage_relationship(:requisition_id, :requisition, type: :append, on_lookup: :relate)
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        estimated_unit_price = Ash.Changeset.get_attribute(changeset, :estimated_unit_price)

        if quantity && estimated_unit_price do
          Ash.Changeset.force_change_attribute(changeset, :estimated_amount, Decimal.mult(quantity, estimated_unit_price))
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:quantity, :estimated_unit_price, :description]
      change fn changeset, _context ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)
        estimated_unit_price = Ash.Changeset.get_attribute(changeset, :estimated_unit_price)

        if quantity && estimated_unit_price do
          Ash.Changeset.force_change_attribute(changeset, :estimated_amount, Decimal.mult(quantity, estimated_unit_price))
        else
          changeset
        end
      end
    end
  end

  validations do
    validate compare(:quantity, greater_than: 0)
    validate compare(:estimated_unit_price, greater_than_or_equal_to: 0)
  end

end
