defmodule UniboExPoc.Expenses.ExpenseLineTaxLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "费用明细-税率桥接占位实体"
  end

  postgres do
    table "expenses_expense_line_tax_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :expenses_expense_line_tax_link

    queries do
      get :get_expenses_expense_line_tax_link, :read
      list :list_expenses_expense_line_tax_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :expense_line, UniboExPoc.Expenses.ExpenseLine do
      public? true
      allow_nil? false
    end
    belongs_to :tax, UniboExPoc.Expenses.Tax do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
