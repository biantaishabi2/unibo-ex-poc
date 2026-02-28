defmodule UniboV4.Purchasing.GoodsReceipt do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Purchasing.GoodsReceipt.Notifier]

  postgres do
    table "goods_receipts"
    repo UniboV4.Repo
  end

  graphql do
    type :goods_receipt

    queries do
      get :get_goods_receipt, :read
      list :list_goods_receipts, :read
    end

    mutations do
      create :create_goods_receipt, :create
      update :confirm_goods_receipt, :confirm
      update :cancel_goods_receipt, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :receipt_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :confirmed, :cancelled]
      default :draft
    end
    attribute :receipt_date, :date, allow_nil?: false
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Purchasing.GoodsReceiptItem
    belongs_to :purchase_order, UniboV4.Purchasing.PurchaseOrder do
      allow_nil? false
    end
    belongs_to :received_by, UniboV4.Accounts.User
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
    end
    update :confirm do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以确认"
      end
      change set_attribute(:status, :confirmed)
    end
    update :cancel do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以取消"
      end
      change set_attribute(:status, :cancelled)
    end
  end

  identities do
    identity :unique_receipt_number, [:receipt_number]
  end

end
