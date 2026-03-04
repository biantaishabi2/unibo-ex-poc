# Workflow: receipt_item_editing — 收货明细编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Purchasing.GoodsReceiptItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "purchasing_goods_receipt_items"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :quantity_received, :integer do
      allow_nil? false
      public? true
    end
    attribute :quantity_accepted, :integer, public?: true
    attribute :quantity_rejected, :integer do
      default 0
      public? true
    end
    attribute :rejection_reason, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :receipt, UniboV4.Purchasing.GoodsReceipt do
      public? true
      allow_nil? false
    end
  end

  actions do
    create :create do
      primary? true
      accept [:product_name, :quantity_received, :quantity_accepted, :quantity_rejected, :rejection_reason]
      argument :receipt_id, :uuid, allow_nil?: false
      change manage_relationship(:receipt_id, :receipt, type: :append, on_lookup: :relate)
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
      accept [:quantity_accepted, :quantity_rejected, :rejection_reason]
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
    validate compare(:quantity_received, greater_than: 0)
  end

end
