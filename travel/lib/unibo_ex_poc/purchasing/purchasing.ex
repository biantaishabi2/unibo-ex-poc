defmodule UniboExPoc.Purchasing do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Purchasing.Supplier
    resource UniboExPoc.Purchasing.Supplier.Version
    resource UniboExPoc.Purchasing.SupplierProduct
    resource UniboExPoc.Purchasing.SupplierProduct.Version
    resource UniboExPoc.Purchasing.PurchaseRequisitionType
    resource UniboExPoc.Purchasing.PurchaseRequisitionType.Version
    resource UniboExPoc.Purchasing.PurchaseRequisition
    resource UniboExPoc.Purchasing.PurchaseRequisition.Version
    resource UniboExPoc.Purchasing.PurchaseRequisitionItem
    resource UniboExPoc.Purchasing.PurchaseRequisitionItem.Version
    resource UniboExPoc.Purchasing.PurchaseOrder
    resource UniboExPoc.Purchasing.PurchaseOrder.Version
    resource UniboExPoc.Purchasing.PurchaseOrderLine
    resource UniboExPoc.Purchasing.PurchaseOrderLine.Version
    resource UniboExPoc.Purchasing.ProductSupplierinfo
    resource UniboExPoc.Purchasing.ProductSupplierinfo.Version
    resource UniboExPoc.Purchasing.GoodsReceipt
    resource UniboExPoc.Purchasing.GoodsReceipt.Version
    resource UniboExPoc.Purchasing.GoodsReceiptItem
    resource UniboExPoc.Purchasing.GoodsReceiptItem.Version
    resource UniboExPoc.Purchasing.Product
    resource UniboExPoc.Purchasing.AccountMove
    resource UniboExPoc.Purchasing.AccountMoveLine
    resource UniboExPoc.Purchasing.Party
  end
end
