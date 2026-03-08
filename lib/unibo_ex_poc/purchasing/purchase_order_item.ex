# Workflow: order_item_editing — 旧版订单行编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Purchasing.PurchaseOrderItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "采购订单明细（旧版简化模型，建议使用 PurchaseOrderLine）"
  end

  postgres do
    table "purchasing_purchase_order_items"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_purchase_order_item

    mutations do
      create :create_purchasing_purchase_order_item, :create
      update :update_purchasing_purchase_order_item, :update
    end

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
      description "已收货数量"
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
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :product_code, :quantity, :unit_price]
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      change set_attribute(:line_amount, expr((quantity * unit_price)))
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:quantity, :unit_price]
      change set_attribute(:line_amount, expr((quantity * unit_price)))
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:quantity, greater_than: 0)
    validate compare(:unit_price, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
