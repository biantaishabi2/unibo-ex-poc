defmodule UniboV4.Expenses.ExpenseLineTaxLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "expenses_expense_line_tax_links"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :expense_line, UniboV4.Expenses.ExpenseLine do
      public? true
      allow_nil? false
    end
    belongs_to :tax, UniboV4.Expenses.Tax do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
