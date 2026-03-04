defmodule UniboV4.Accounting do
  use Ash.Domain

  resources do
    resource UniboV4.Accounting.GlAccount
    resource UniboV4.Accounting.JournalEntry
    resource UniboV4.Accounting.JournalEntryLine
    resource UniboV4.Accounting.Invoice
    resource UniboV4.Accounting.InvoiceItem
    resource UniboV4.Accounting.Payment
    resource UniboV4.Accounting.PaymentApplication
    resource UniboV4.Accounting.PartialReconcile
    resource UniboV4.Accounting.FullReconcile
    resource UniboV4.Accounting.Budget
    resource UniboV4.Accounting.BudgetItem
    resource UniboV4.Accounting.BillingAccount
    resource UniboV4.Accounting.User
    resource UniboV4.Accounting.Partner
    resource UniboV4.Accounting.Journal
    resource UniboV4.Accounting.Tax
    resource UniboV4.Accounting.JournalEntryLineTaxRel
  end
end
