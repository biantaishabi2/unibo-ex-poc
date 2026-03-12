defmodule UniboExPoc.Accounting do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Accounting.GlAccount
    resource UniboExPoc.Accounting.JournalEntry
    resource UniboExPoc.Accounting.JournalEntryLine
    resource UniboExPoc.Accounting.Invoice
    resource UniboExPoc.Accounting.InvoiceItem
    resource UniboExPoc.Accounting.Payment
    resource UniboExPoc.Accounting.PaymentApplication
    resource UniboExPoc.Accounting.PartialReconcile
    resource UniboExPoc.Accounting.FullReconcile
    resource UniboExPoc.Accounting.BillingAccount
    resource UniboExPoc.Accounting.Journal
    resource UniboExPoc.Accounting.Tax
    resource UniboExPoc.Accounting.JournalEntryLineTaxRel
    resource UniboExPoc.Accounting.Party
  end
end
