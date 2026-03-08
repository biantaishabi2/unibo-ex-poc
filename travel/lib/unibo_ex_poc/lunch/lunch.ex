defmodule UniboExPoc.Lunch do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Lunch.LunchSupplier
    resource UniboExPoc.Lunch.LunchSupplier.Version
    resource UniboExPoc.Lunch.LunchProduct
    resource UniboExPoc.Lunch.LunchProductTranslation
    resource UniboExPoc.Lunch.LunchProduct.Version
    resource UniboExPoc.Lunch.LunchTopping
    resource UniboExPoc.Lunch.LunchTopping.Version
    resource UniboExPoc.Lunch.LunchOrder
    resource UniboExPoc.Lunch.LunchOrder.Version
    resource UniboExPoc.Lunch.LunchCashMove
    resource UniboExPoc.Lunch.LunchCashMove.Version
    resource UniboExPoc.Lunch.LunchCategory
    resource UniboExPoc.Lunch.LunchCategoryTranslation
    resource UniboExPoc.Lunch.LunchCategory.Version
    resource UniboExPoc.Lunch.LunchLocation
    resource UniboExPoc.Lunch.LunchLocation.Version
    resource UniboExPoc.Lunch.LunchProductFavoriteUserLink
    resource UniboExPoc.Lunch.LunchOrderTopping1Link
    resource UniboExPoc.Lunch.LunchOrderTopping2Link
    resource UniboExPoc.Lunch.LunchOrderTopping3Link
    resource UniboExPoc.Lunch.Party
  end
end
