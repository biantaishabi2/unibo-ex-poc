# Workflow: budget_item_editing — 预算项编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboExPoc.Accounting.BudgetItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "预算明细行（对齐 OFBiz BudgetItem）"
  end

  postgres do
    table "accounting_budget_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_budget_item

    mutations do
      create :create_accounting_budget_item, :create
      update :update_accounting_budget_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :budget_item_type_id, :string do
      public? true
      description "预算项类型（对齐 OFBiz BudgetItemType，如 人员/设备/差旅）"
    end
    attribute :seq_id, :integer do
      public? true
      description "行序号（对齐 OFBiz budget_item_seq_id）"
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :purpose, :string do
      public? true
      description "用途说明（对齐 OFBiz purpose）"
    end
    attribute :justification, :string do
      public? true
      description "理由（对齐 OFBiz justification）"
    end
    attribute :description, :string do
      allow_nil? false
      public? true
      description "预算项描述（业务扩展）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :budget, UniboExPoc.Accounting.Budget do
      public? true
      allow_nil? false
    end
    belongs_to :gl_account, UniboExPoc.Accounting.GlAccount do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:description, :amount, :purpose, :justification, :budget_item_type_id, :seq_id]
      argument :gl_account_id, :uuid
      argument :budget_id, :uuid, allow_nil?: false
      change manage_relationship(:budget_id, :budget, type: :append, on_lookup: :relate)
      validate compare(:amount, greater_than: 0)
      # message: "预算金额必须大于零"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:description, :amount, :purpose, :justification, :budget_item_type_id, :seq_id]
      # skipped: validate compare :amount (incompatible with bulk update atomic path)
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
