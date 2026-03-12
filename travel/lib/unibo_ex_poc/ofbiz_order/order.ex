defmodule UniboExPoc.Ofbiz.Order do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Order.OrderAdjustment
<<<<<<< Updated upstream
    resource UniboExPoc.Ofbiz.Order.OrderAdjustmentType
    resource UniboExPoc.Ofbiz.Order.OrderHeader
    resource UniboExPoc.Ofbiz.Order.OrderItem
    resource UniboExPoc.Ofbiz.Order.OrderItemType
    resource UniboExPoc.Ofbiz.Order.OrderPaymentPreference
    resource UniboExPoc.Ofbiz.Order.OrderRole
    resource UniboExPoc.Ofbiz.Order.OrderType
    resource UniboExPoc.Ofbiz.Order.Quote
=======
    resource UniboExPoc.Ofbiz.Order.OrderAdjustment.Version
    resource UniboExPoc.Ofbiz.Order.OrderAdjustmentType
    resource UniboExPoc.Ofbiz.Order.OrderAdjustmentType.Version
    resource UniboExPoc.Ofbiz.Order.OrderHeader
    resource UniboExPoc.Ofbiz.Order.OrderHeader.Version
    resource UniboExPoc.Ofbiz.Order.OrderItem
    resource UniboExPoc.Ofbiz.Order.OrderItem.Version
    resource UniboExPoc.Ofbiz.Order.OrderItemType
    resource UniboExPoc.Ofbiz.Order.OrderItemType.Version
    resource UniboExPoc.Ofbiz.Order.OrderPaymentPreference
    resource UniboExPoc.Ofbiz.Order.OrderPaymentPreference.Version
    resource UniboExPoc.Ofbiz.Order.OrderRole
    resource UniboExPoc.Ofbiz.Order.OrderType
    resource UniboExPoc.Ofbiz.Order.OrderType.Version
    resource UniboExPoc.Ofbiz.Order.Quote
    resource UniboExPoc.Ofbiz.Order.Quote.Version
>>>>>>> Stashed changes
    resource UniboExPoc.Ofbiz.Order.QuoteItem
    resource UniboExPoc.Ofbiz.Order.QuoteNote
<<<<<<< Updated upstream
    resource UniboExPoc.Ofbiz.Order.QuoteType
    resource UniboExPoc.Ofbiz.Order.CustRequest
    resource UniboExPoc.Ofbiz.Order.CustRequestCategory
    resource UniboExPoc.Ofbiz.Order.CustRequestType
    resource UniboExPoc.Ofbiz.Order.Requirement
    resource UniboExPoc.Ofbiz.Order.RequirementType
=======
    resource UniboExPoc.Ofbiz.Order.QuoteNote.Version
    resource UniboExPoc.Ofbiz.Order.QuoteType
    resource UniboExPoc.Ofbiz.Order.QuoteType.Version
    resource UniboExPoc.Ofbiz.Order.CustRequest
    resource UniboExPoc.Ofbiz.Order.CustRequest.Version
    resource UniboExPoc.Ofbiz.Order.CustRequestCategory
    resource UniboExPoc.Ofbiz.Order.CustRequestCategory.Version
    resource UniboExPoc.Ofbiz.Order.CustRequestType
    resource UniboExPoc.Ofbiz.Order.CustRequestType.Version
>>>>>>> Stashed changes
    resource UniboExPoc.Ofbiz.Order.ReturnHeader
    resource UniboExPoc.Ofbiz.Order.ReturnHeaderType
    resource UniboExPoc.Ofbiz.Order.ReturnItem
    resource UniboExPoc.Ofbiz.Order.ReturnItemResponse
    resource UniboExPoc.Ofbiz.Order.ReturnItemType
<<<<<<< Updated upstream
    resource UniboExPoc.Ofbiz.Order.ReturnReason
    resource UniboExPoc.Ofbiz.Order.ReturnType
    resource UniboExPoc.Ofbiz.Order.ShoppingList
    resource UniboExPoc.Ofbiz.Order.ShoppingListType
=======
    resource UniboExPoc.Ofbiz.Order.ReturnItemType.Version
    resource UniboExPoc.Ofbiz.Order.ReturnReason
    resource UniboExPoc.Ofbiz.Order.ReturnReason.Version
    resource UniboExPoc.Ofbiz.Order.ReturnType
    resource UniboExPoc.Ofbiz.Order.ReturnType.Version
    resource UniboExPoc.Ofbiz.Order.ShoppingList
    resource UniboExPoc.Ofbiz.Order.ShoppingList.Version
    resource UniboExPoc.Ofbiz.Order.ShoppingListType
    resource UniboExPoc.Ofbiz.Order.ShoppingListType.Version
>>>>>>> Stashed changes
  end
end
