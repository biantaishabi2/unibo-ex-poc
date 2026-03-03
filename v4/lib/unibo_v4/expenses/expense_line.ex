# Workflow: expense_line_edit_flow — 费用明细编辑与拆分流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   split --> [*]
# ```
defmodule UniboV4.Expenses.ExpenseLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "expenses_expense_lines"
    repo UniboV4.Repo
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
    end
    attribute :quantity, :decimal do
      allow_nil? false
      default 1
      public? true
    end
    attribute :price_unit, :decimal do
      allow_nil? false
      public? true
    end
    attribute :payment_mode, :atom do
      allow_nil? false
      constraints one_of: [:own_account, :company_account]
      public? true
    end
    attribute :currency_rate, :decimal, public?: true
    attribute :total_amount_currency, :decimal, public?: true
    attribute :total_amount, :decimal, public?: true
    attribute :tax_amount_currency, :decimal, public?: true
    attribute :tax_amount, :decimal, public?: true
    attribute :untaxed_amount_currency, :decimal, public?: true
    attribute :expense_date, :date do
      allow_nil? false
      public? true
    end
    attribute :receipt_reference, :string, public?: true
    attribute :analytic_distribution, :string, public?: true
    attribute :is_duplicate, :boolean, public?: true
    attribute :state, :atom do
      constraints one_of: [:draft, :reported, :approved, :refused, :done]
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :report, UniboV4.Expenses.ExpenseReport do
      public? true
    end
    belongs_to :product, UniboV4.Expenses.Product do
      public? true
      allow_nil? false
    end
    belongs_to :category, UniboV4.Expenses.ExpenseCategory do
      public? true
    end
    belongs_to :employee, UniboV4.Expenses.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :currency, UniboV4.Expenses.Currency do
      public? true
      allow_nil? false
    end
    many_to_many :tax_ids, UniboV4.Expenses.Tax do
      public? true
      through UniboV4.Expenses.ExpenseLineTaxLink
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
      # TODO: 不支持的 change effect relate_actor_employee
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
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
      accept [:description, :quantity, :price_unit, :expense_date, :receipt_reference, :payment_mode, :currency_rate, :analytic_distribution, :notes]
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
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
    update :split do
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
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
    validate compare(:total_amount, greater_than: 0)
    # TODO: 不支持的校验规则 prevent_delete
  end

end
