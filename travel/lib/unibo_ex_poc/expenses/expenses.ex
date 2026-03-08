defmodule UniboExPoc.Expenses do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Expenses.ExpenseReport
    resource UniboExPoc.Expenses.ExpenseReport.Version
    resource UniboExPoc.Expenses.ExpenseLine
    resource UniboExPoc.Expenses.ExpenseLine.Version
    resource UniboExPoc.Expenses.ExpenseCategory
    resource UniboExPoc.Expenses.ExpenseCategory.Version
    resource UniboExPoc.Expenses.ExpenseLineTaxLink
    resource UniboExPoc.Expenses.AccountMove
    resource UniboExPoc.Expenses.Account
    resource UniboExPoc.Expenses.Currency
    resource UniboExPoc.Expenses.Employee
    resource UniboExPoc.Expenses.Product
    resource UniboExPoc.Expenses.Tax
    resource UniboExPoc.Expenses.Journal
    resource UniboExPoc.Expenses.PaymentMethodLine
    resource UniboExPoc.Expenses.Party
  end
end
