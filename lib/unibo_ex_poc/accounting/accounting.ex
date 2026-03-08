defmodule UniboV4.Accounting do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Accounting.GlAccount
    resource UniboV4.Accounting.GlAccount.Version
    resource UniboV4.Accounting.JournalEntry
    resource UniboV4.Accounting.JournalEntry.Version
    resource UniboV4.Accounting.JournalEntryLine
    resource UniboV4.Accounting.JournalEntryLine.Version
    resource UniboV4.Accounting.Invoice
    resource UniboV4.Accounting.Invoice.Version
    resource UniboV4.Accounting.InvoiceItem
    resource UniboV4.Accounting.InvoiceItem.Version
    resource UniboV4.Accounting.Payment
    resource UniboV4.Accounting.Payment.Version
    resource UniboV4.Accounting.PaymentApplication
    resource UniboV4.Accounting.PaymentApplication.Version
    resource UniboV4.Accounting.PartialReconcile
    resource UniboV4.Accounting.PartialReconcile.Version
    resource UniboV4.Accounting.FullReconcile
    resource UniboV4.Accounting.FullReconcile.Version
    resource UniboV4.Accounting.Budget
    resource UniboV4.Accounting.Budget.Version
    resource UniboV4.Accounting.BudgetItem
    resource UniboV4.Accounting.BudgetItem.Version
    resource UniboV4.Accounting.BillingAccount
    resource UniboV4.Accounting.BillingAccount.Version
    resource UniboV4.Accounting.Journal
    resource UniboV4.Accounting.Tax
    resource UniboV4.Accounting.JournalEntryLineTaxRel
    resource UniboV4.Accounting.Party
  end
end
