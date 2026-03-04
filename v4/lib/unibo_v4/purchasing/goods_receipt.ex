# Workflow: goods_receipt_lifecycle — 收货流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> confirm
#   confirm --> cancel
#   cancel --> [*]
# ```
defmodule UniboV4.Purchasing.GoodsReceipt do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Purchasing.GoodsReceipt.Notifier]

  postgres do
    table "purchasing_goods_receipts"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :receipt_number, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :confirmed, :cancelled]
      default :draft
      public? true
    end
    attribute :receipt_date, :date do
      allow_nil? false
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Purchasing.GoodsReceiptItem do
      public? true
      destination_attribute :receipt_id
    end
    belongs_to :purchase_order, UniboV4.Purchasing.PurchaseOrder do
      public? true
      allow_nil? false
    end
    belongs_to :received_by, UniboV4.Purchasing.User do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:receipt_number, :receipt_date, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      argument :purchase_order_id, :uuid, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:purchase_order_id, :purchase_order, type: :append, on_lookup: :relate)
      validate present(:receipt_number)
      change relate_actor(:received_by)
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
    update :confirm do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      change set_attribute(:status, :confirmed)
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
    update :cancel do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以取消"
      change set_attribute(:status, :cancelled)
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
    identity :unique_receipt_number, [:receipt_number]
  end

end
