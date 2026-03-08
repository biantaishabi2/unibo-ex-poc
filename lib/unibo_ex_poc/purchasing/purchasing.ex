defmodule UniboV4.Purchasing do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Purchasing.Supplier
    resource UniboV4.Purchasing.Supplier.Version
    resource UniboV4.Purchasing.SupplierProduct
    resource UniboV4.Purchasing.SupplierProduct.Version
    resource UniboV4.Purchasing.PurchaseRequisitionType
    resource UniboV4.Purchasing.PurchaseRequisitionType.Version
    resource UniboV4.Purchasing.PurchaseRequisition
    resource UniboV4.Purchasing.PurchaseRequisition.Version
    resource UniboV4.Purchasing.PurchaseRequisitionItem
    resource UniboV4.Purchasing.PurchaseRequisitionItem.Version
    resource UniboV4.Purchasing.PurchaseOrder
    resource UniboV4.Purchasing.PurchaseOrder.Version
    resource UniboV4.Purchasing.PurchaseOrderLine
    resource UniboV4.Purchasing.PurchaseOrderLine.Version
    resource UniboV4.Purchasing.PurchaseOrderItem
    resource UniboV4.Purchasing.PurchaseOrderItem.Version
    resource UniboV4.Purchasing.ProductSupplierinfo
    resource UniboV4.Purchasing.ProductSupplierinfo.Version
    resource UniboV4.Purchasing.GoodsReceipt
    resource UniboV4.Purchasing.GoodsReceipt.Version
    resource UniboV4.Purchasing.GoodsReceiptItem
    resource UniboV4.Purchasing.GoodsReceiptItem.Version
    resource UniboV4.Purchasing.Product
    resource UniboV4.Purchasing.AccountMove
    resource UniboV4.Purchasing.AccountMoveLine
    resource UniboV4.Purchasing.Party
  end
end
