# Workflow: requisition_item_editing — 采购申请行编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboExPoc.Purchasing.PurchaseRequisitionItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "采购申请/协议明细行（对齐 OFBiz Requirement），记录产品、数量、单价，支持已下单数量追踪"
  end

  postgres do
    table "purchasing_purchase_requisition_items"
    repo UniboExPoc.Repo
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
    attribute :status_id, :string do
      public? true
      description "需求状态（对齐 OFBiz Requirement.status_id）"
    end
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
      description "需求数量（对齐 OFBiz Requirement.quantity）"
    end
    attribute :description, :string do
      public? true
      description "描述（对齐 OFBiz Requirement.description）"
    end
    attribute :required_by_date, :date do
      public? true
      description "需求截止日（对齐 OFBiz Requirement.required_by_date）"
    end
    attribute :estimated_budget, :decimal do
      public? true
      description "预估预算（对齐 OFBiz Requirement.estimated_budget）"
    end
    attribute :reason, :string do
      public? true
      description "原因（对齐 OFBiz Requirement.reason）"
    end
    attribute :product_name, :string do
      allow_nil? false
      public? true
      description "产品名称（业务扩展，OFBiz 通过 product_id 关联）"
    end
    attribute :product_description_variants, :string do
      public? true
      description "产品变体描述"
    end
    attribute :unit_price, :decimal do
      default 0
      public? true
      description "单价（业务扩展，对齐 OrderItem.unit_price 命名）"
    end
    attribute :estimated_amount, :decimal do
      public? true
      description "预估金额（computed = quantity * unit_price）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :qty_ordered, :decimal, {UniboExPoc.Purchasing.Calculations.PurchaseRequisitionItem.QtyOrdered, []}
  end

  relationships do
    belongs_to :requisition, UniboExPoc.Purchasing.PurchaseRequisition do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboExPoc.Purchasing.Product do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :product_description_variants, :quantity, :unit_price, :required_by_date, :description, :reason, :status_id]
      argument :product_id, :uuid
      argument :requisition_id, :uuid, allow_nil?: false
      change manage_relationship(:requisition_id, :requisition, type: :append, on_lookup: :relate)
      change set_attribute(:estimated_amount, expr((quantity * unit_price)))
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:quantity, :unit_price, :required_by_date, :description, :reason, :status_id]
      change set_attribute(:estimated_amount, expr((quantity * unit_price)))
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
