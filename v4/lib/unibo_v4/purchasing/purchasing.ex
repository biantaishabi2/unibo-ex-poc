defmodule UniboV4.Purchasing do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Purchasing.Supplier
    resource UniboV4.Purchasing.SupplierProduct
    resource UniboV4.Purchasing.PurchaseRequisitionType
    resource UniboV4.Purchasing.PurchaseRequisition
    resource UniboV4.Purchasing.PurchaseRequisitionItem
    resource UniboV4.Purchasing.PurchaseOrder
    resource UniboV4.Purchasing.PurchaseOrderLine
    resource UniboV4.Purchasing.PurchaseOrderItem
    resource UniboV4.Purchasing.ProductSupplierinfo
    resource UniboV4.Purchasing.GoodsReceipt
    resource UniboV4.Purchasing.GoodsReceiptItem
    resource UniboV4.Purchasing.User
    resource UniboV4.Purchasing.Product
    resource UniboV4.Purchasing.Company
    resource UniboV4.Purchasing.AccountMove
    resource UniboV4.Purchasing.AccountMoveLine
  end
end
