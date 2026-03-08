# Workflow: expense_line_edit_flow — 费用明细编辑与拆分流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   split --> [*]
# ```
defmodule UniboExPoc.Expenses.ExpenseLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "费用明细"
  end

  postgres do
    table "expenses_expense_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :expenses_expense_line

    mutations do
      create :create_expenses_expense_line, :create
      update :update_expenses_expense_line, :update
      update :split_expenses_expense_line, :split
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :description, :string do
      allow_nil? false
      public? true
      description "费用描述"
    end
    attribute :quantity, :decimal do
      allow_nil? false
      default 1
      public? true
      description "数量"
    end
    attribute :price_unit, :decimal do
      allow_nil? false
      public? true
      description "单价"
    end
    attribute :payment_mode, :atom do
      allow_nil? false
      constraints one_of: [:own_account, :company_account]
      public? true
      description "支付方式（员工垫付 / 公司支付）"
    end
    attribute :currency_rate, :decimal do
      public? true
      description "汇率（可手动覆盖，支持自定义汇率）(规则31/32)"
    end
    attribute :total_amount_currency, :decimal do
      public? true
      description "费用币种金额"
    end
    attribute :total_amount, :decimal do
      public? true
      description "公司币种金额"
    end
    attribute :tax_amount_currency, :decimal do
      public? true
      description "费用币种税额"
    end
    attribute :tax_amount, :decimal do
      public? true
      description "公司币种税额"
    end
    attribute :untaxed_amount_currency, :decimal do
      public? true
      description "费用币种不含税金额"
    end
    attribute :expense_date, :date do
      allow_nil? false
      public? true
      description "费用发生日期"
    end
    attribute :receipt_reference, :string do
      public? true
      description "发票/收据号"
    end
    attribute :analytic_distribution, :string do
      public? true
      description "分析分配"
    end
    attribute :is_duplicate, :boolean do
      public? true
      description "重复标记"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :reported, :approved, :refused, :done]
      public? true
      description "费用明细状态（从 report 状态派生）"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :report, UniboExPoc.Expenses.ExpenseReport do
      public? true
    end
    belongs_to :product, UniboExPoc.Expenses.Product do
      public? true
      allow_nil? false
    end
    belongs_to :category, UniboExPoc.Expenses.ExpenseCategory do
      public? true
    end
    belongs_to :employee, UniboExPoc.Expenses.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :currency, UniboExPoc.Expenses.Currency do
      public? true
      allow_nil? false
    end
    many_to_many :tax_ids, UniboExPoc.Expenses.Tax do
      public? true
      through UniboExPoc.Expenses.ExpenseLineTaxLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:description, :quantity, :price_unit, :expense_date, :receipt_reference, :payment_mode, :currency_rate, :analytic_distribution, :notes]
      argument :product_id, :uuid, allow_nil?: false
      argument :employee_id, :uuid, allow_nil?: false
      argument :currency_id, :uuid, allow_nil?: false
      argument :tax_ids, {:array, :string}
      argument :category_id, :uuid
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change manage_relationship(:currency_id, :currency, type: :append, on_lookup: :relate)
      validate present(:product_id)
      # message: "费用类型不能为空"
      change UniboExPoc.Expenses.Changes.ExpenseLine.CreateCall1
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:description, :quantity, :price_unit, :expense_date, :receipt_reference, :payment_mode, :currency_rate, :analytic_distribution, :notes]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :split do
      description "费用拆分（50/50 拆为两条明细）(规则35)"
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:total_amount, greater_than: 0)
    # prevent_destroy: 在 destroy action 中通过 change 拒绝操作
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
