defmodule UniboV4.Expenses do
  use Ash.Domain

  resources do
    resource UniboV4.Expenses.ExpenseReport
    resource UniboV4.Expenses.ExpenseLine
    resource UniboV4.Expenses.ExpenseCategory
    resource UniboV4.Expenses.ExpenseLineTaxLink
    resource UniboV4.Expenses.AccountMove
    resource UniboV4.Expenses.Account
    resource UniboV4.Expenses.Currency
    resource UniboV4.Expenses.Employee
    resource UniboV4.Expenses.Product
    resource UniboV4.Expenses.Tax
    resource UniboV4.Expenses.User
    resource UniboV4.Expenses.Company
    resource UniboV4.Expenses.Journal
    resource UniboV4.Expenses.PaymentMethodLine
  end
end
