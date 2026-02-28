defmodule UniboV4.Accounting do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Accounting.GlAccount
    resource UniboV4.Accounting.JournalEntry
    resource UniboV4.Accounting.JournalEntryLine
    resource UniboV4.Accounting.Invoice
    resource UniboV4.Accounting.InvoiceItem
    resource UniboV4.Accounting.Payment
    resource UniboV4.Accounting.PaymentApplication
    resource UniboV4.Accounting.Budget
    resource UniboV4.Accounting.BudgetItem
    resource UniboV4.Accounting.BillingAccount
  end
end
