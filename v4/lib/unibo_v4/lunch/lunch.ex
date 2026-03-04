defmodule UniboV4.Lunch do
  use Ash.Domain

  resources do
    resource UniboV4.Lunch.LunchSupplier
    resource UniboV4.Lunch.LunchProduct
    resource UniboV4.Lunch.LunchProductTranslation
    resource UniboV4.Lunch.LunchTopping
    resource UniboV4.Lunch.LunchOrder
    resource UniboV4.Lunch.LunchCashMove
    resource UniboV4.Lunch.LunchCategory
    resource UniboV4.Lunch.LunchCategoryTranslation
    resource UniboV4.Lunch.LunchLocation
    resource UniboV4.Lunch.LunchProductFavoriteUserLink
    resource UniboV4.Lunch.LunchOrderTopping1Link
    resource UniboV4.Lunch.LunchOrderTopping2Link
    resource UniboV4.Lunch.LunchOrderTopping3Link
    resource UniboV4.Lunch.User
    resource UniboV4.Lunch.Partner
  end
end
