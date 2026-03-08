# Workflow: goods_receipt_lifecycle — 收货流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> confirm
#   confirm --> cancel
#   cancel --> [*]
# ```
defmodule UniboExPoc.Purchasing.GoodsReceipt do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Purchasing.GoodsReceipt.Notifier]

  resource do
    description "收货单"
  end

  postgres do
    table "purchasing_goods_receipts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :purchasing_goods_receipt

    queries do
      get :get_purchasing_goods_receipt, :read
      list :list_purchasing_goods_receipts, :read
      get :get_list_purchasing_goods_receipt, :list
      list :list_list_purchasing_goods_receipts, :list
      get :get_search_purchasing_goods_receipt, :search
      list :list_search_purchasing_goods_receipts, :search
      get :get_get_purchasing_goods_receipt, :get
      list :list_get_purchasing_goods_receipts, :get
      get :get_preview_purchasing_goods_receipt, :preview
      list :list_preview_purchasing_goods_receipts, :preview
      get :get_compute_purchasing_goods_receipt, :compute
      list :list_compute_purchasing_goods_receipts, :compute
      get :get_lookup_purchasing_goods_receipt, :lookup
      list :list_lookup_purchasing_goods_receipts, :lookup
    end

    mutations do
      create :create_purchasing_goods_receipt, :create
      update :confirm_purchasing_goods_receipt, :confirm
      update :cancel_purchasing_goods_receipt, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :receipt_number, :string do
      allow_nil? false
      public? true
      description "收货单号"
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
    has_many :items, UniboExPoc.Purchasing.GoodsReceiptItem do
      public? true
      destination_attribute :receipt_id
    end
    belongs_to :purchase_order, UniboExPoc.Purchasing.PurchaseOrder do
      public? true
      allow_nil? false
    end
    belongs_to :received_by, UniboExPoc.Purchasing.Party do
      public? true
      source_attribute :received_by_party_id
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
      change set_attribute(:id, expr(id))
    end
    read :list do
      description "列表查询"
    end
    read :search do
      description "条件检索"
    end
    read :get do
      description "详情查询"
    end
    read :preview do
      description "预览查询"
    end
    read :compute do
      description "计算查询"
    end
    read :lookup do
      description "快速检索"
    end
    update :confirm do
      description "确认收货"
      primary? true
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消收货"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_receipt_number, [:receipt_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
