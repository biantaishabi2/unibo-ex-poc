# Workflow: requisition_type_lifecycle — 采购申请类型管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboExPoc.Purchasing.PurchaseRequisitionType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "采购申请类型（对齐 OFBiz RequirementType），控制独占/多选模式和数量/行复制行为"
  end

  postgres do
    table "purchasing_purchase_requisition_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :purchasing_purchase_requisition_type

    queries do
      get :get_purchasing_purchase_requisition_type, :read
      list :list_purchasing_purchase_requisition_types, :read
      get :get_list_purchasing_purchase_requisition_type, :list
      list :list_list_purchasing_purchase_requisition_types, :list
      get :get_search_purchasing_purchase_requisition_type, :search
      list :list_search_purchasing_purchase_requisition_types, :search
      get :get_get_purchasing_purchase_requisition_type, :get
      list :list_get_purchasing_purchase_requisition_types, :get
      get :get_preview_purchasing_purchase_requisition_type, :preview
      list :list_preview_purchasing_purchase_requisition_types, :preview
      get :get_compute_purchasing_purchase_requisition_type, :compute
      list :list_compute_purchasing_purchase_requisition_types, :compute
      get :get_lookup_purchasing_purchase_requisition_type, :lookup
      list :list_lookup_purchasing_purchase_requisition_types, :lookup
    end

    mutations do
      create :create_purchasing_purchase_requisition_type, :create
      update :update_purchasing_purchase_requisition_type, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :description, :string do
      allow_nil? false
      public? true
      description "类型描述（对齐 OFBiz RequirementType.description）"
    end
    attribute :has_table, :boolean do
      default false
      public? true
      description "是否有扩展表（对齐 OFBiz has_table）"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "类型名称（业务扩展，可翻译）"
    end
    attribute :sequence, :integer do
      default 10
      public? true
      description "排序权重"
    end
    attribute :exclusive, :atom do
      constraints one_of: [:exclusive, :multiple]
      default :multiple
      public? true
      description "独占模式（exclusive=只选一家供应商）或多选模式（multiple=可多个 RFQ）"
    end
    attribute :quantity_copy, :atom do
      constraints one_of: [:copy, :none]
      default :copy
      public? true
      description "是否复制协议数量到采购订单（copy=使用协议数量，none=手动设置）"
    end
    attribute :line_copy, :atom do
      constraints one_of: [:copy, :none]
      default :copy
      public? true
      description "是否自动复制协议行到采购订单（copy=自动创建，none=不自动创建）"
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :parent_type, UniboExPoc.Purchasing.PurchaseRequisitionType do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :sequence, :exclusive, :quantity_copy, :line_copy, :active, :parent_type_id, :has_table]
      validate present(:name)
      validate present(:description)
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
    update :update do
      primary? true
      accept [:name, :description, :sequence, :exclusive, :quantity_copy, :line_copy, :active, :parent_type_id, :has_table]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
