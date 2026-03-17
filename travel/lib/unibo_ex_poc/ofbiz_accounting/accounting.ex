defmodule UniboExPoc.Ofbiz.Accounting do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Accounting.FinAccount
    resource UniboExPoc.Ofbiz.Accounting.FinAccountTrans
    resource UniboExPoc.Ofbiz.Accounting.FinAccountTransType
    resource UniboExPoc.Ofbiz.Accounting.FinAccountType
    resource UniboExPoc.Ofbiz.Accounting.FixedAsset
    resource UniboExPoc.Ofbiz.Accounting.FixedAssetType
    resource UniboExPoc.Ofbiz.Accounting.Invoice
    resource UniboExPoc.Ofbiz.Accounting.InvoiceItem
    resource UniboExPoc.Ofbiz.Accounting.InvoiceItemAttribute
    resource UniboExPoc.Ofbiz.Accounting.InvoiceItemType
    resource UniboExPoc.Ofbiz.Accounting.InvoiceType
    resource UniboExPoc.Ofbiz.Accounting.AcctgTrans
    resource UniboExPoc.Ofbiz.Accounting.AcctgTransEntry
    resource UniboExPoc.Ofbiz.Accounting.AcctgTransEntryType
    resource UniboExPoc.Ofbiz.Accounting.AcctgTransType
    resource UniboExPoc.Ofbiz.Accounting.GlAccount
    resource UniboExPoc.Ofbiz.Accounting.GlAccountClass
    resource UniboExPoc.Ofbiz.Accounting.GlAccountType
    resource UniboExPoc.Ofbiz.Accounting.GlFiscalType
    resource UniboExPoc.Ofbiz.Accounting.GlJournal
    resource UniboExPoc.Ofbiz.Accounting.GlReconciliation
    resource UniboExPoc.Ofbiz.Accounting.GlResourceType
    resource UniboExPoc.Ofbiz.Accounting.GlXbrlClass
    resource UniboExPoc.Ofbiz.Accounting.SettlementTerm
    resource UniboExPoc.Ofbiz.Accounting.BillingAccount
    resource UniboExPoc.Ofbiz.Accounting.CreditCard
    resource UniboExPoc.Ofbiz.Accounting.EftAccount
    resource UniboExPoc.Ofbiz.Accounting.GiftCard
    resource UniboExPoc.Ofbiz.Accounting.Payment
    resource UniboExPoc.Ofbiz.Accounting.PaymentApplication
    resource UniboExPoc.Ofbiz.Accounting.PaymentMethod
    resource UniboExPoc.Ofbiz.Accounting.PaymentMethodType
    resource UniboExPoc.Ofbiz.Accounting.PaymentType
    resource UniboExPoc.Ofbiz.Accounting.PaymentGatewayConfigType
    resource UniboExPoc.Ofbiz.Accounting.PaymentGatewayConfig
    resource UniboExPoc.Ofbiz.Accounting.PaymentGatewayResponse
    resource UniboExPoc.Ofbiz.Accounting.TaxAuthority
    resource UniboExPoc.Ofbiz.Accounting.TaxAuthorityRateProduct
    resource UniboExPoc.Ofbiz.Accounting.TaxAuthorityRateType
  end
end
