# Workflow: receipt_item_editing — 收货明细编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboExPoc.Purchasing.GoodsReceiptItem do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "收货单明细"
  end

  postgres do
    table "purchasing_goods_receipt_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :purchasing_goods_receipt_item

    mutations do
      create :create_purchasing_goods_receipt_item, :create
      update :update_purchasing_goods_receipt_item, :update
    end

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
      description "本次收货数量"
    end
    attribute :quantity_accepted, :integer do
      public? true
      description "合格数量"
    end
    attribute :quantity_rejected, :integer do
      default 0
      public? true
      description "不合格数量"
    end
    attribute :rejection_reason, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :receipt, UniboExPoc.Purchasing.GoodsReceipt do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Goods Receipt Item via Create. doc_url: graphql://contract/purchasing/create_purchasing_goods_receipt_item"
      primary? true
      accept [:product_name, :quantity_received, :quantity_accepted, :quantity_rejected, :rejection_reason]
      argument :receipt_id, :uuid, allow_nil?: false
      change manage_relationship(:receipt_id, :receipt, type: :append, on_lookup: :relate)
    end
    update :update do
      description "Update Goods Receipt Item via Update. doc_url: graphql://contract/purchasing/update_purchasing_goods_receipt_item"
      primary? true
      accept [:quantity_accepted, :quantity_rejected, :rejection_reason]
      require_atomic? false
    end
  end

  validations do
    validate compare(:quantity_received, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
