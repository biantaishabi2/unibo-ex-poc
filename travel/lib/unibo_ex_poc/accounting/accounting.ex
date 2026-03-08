defmodule UniboExPoc.Accounting do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Accounting.GlAccount
    resource UniboExPoc.Accounting.GlAccount.Version
    resource UniboExPoc.Accounting.JournalEntry
    resource UniboExPoc.Accounting.JournalEntry.Version
    resource UniboExPoc.Accounting.JournalEntryLine
    resource UniboExPoc.Accounting.JournalEntryLine.Version
    resource UniboExPoc.Accounting.Invoice
    resource UniboExPoc.Accounting.Invoice.Version
    resource UniboExPoc.Accounting.InvoiceItem
    resource UniboExPoc.Accounting.InvoiceItem.Version
    resource UniboExPoc.Accounting.Payment
    resource UniboExPoc.Accounting.Payment.Version
    resource UniboExPoc.Accounting.PaymentApplication
    resource UniboExPoc.Accounting.PaymentApplication.Version
    resource UniboExPoc.Accounting.PartialReconcile
    resource UniboExPoc.Accounting.PartialReconcile.Version
    resource UniboExPoc.Accounting.FullReconcile
    resource UniboExPoc.Accounting.FullReconcile.Version
    resource UniboExPoc.Accounting.Budget
    resource UniboExPoc.Accounting.Budget.Version
    resource UniboExPoc.Accounting.BudgetItem
    resource UniboExPoc.Accounting.BudgetItem.Version
    resource UniboExPoc.Accounting.BillingAccount
    resource UniboExPoc.Accounting.BillingAccount.Version
    resource UniboExPoc.Accounting.Journal
    resource UniboExPoc.Accounting.Tax
    resource UniboExPoc.Accounting.JournalEntryLineTaxRel
    resource UniboExPoc.Accounting.Party
  end
end
