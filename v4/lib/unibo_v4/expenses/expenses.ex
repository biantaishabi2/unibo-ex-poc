defmodule UniboV4.Expenses do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Expenses.ExpenseReport
    resource UniboV4.Expenses.ExpenseLine
    resource UniboV4.Expenses.ExpenseCategory
  end
end
