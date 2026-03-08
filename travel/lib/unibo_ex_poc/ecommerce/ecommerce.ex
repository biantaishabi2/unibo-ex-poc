defmodule UniboExPoc.Ecommerce do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ecommerce.ProductTemplate
    resource UniboExPoc.Ecommerce.ProductTemplateTranslation
    resource UniboExPoc.Ecommerce.ProductTemplate.Version
    resource UniboExPoc.Ecommerce.ProductVariant
    resource UniboExPoc.Ecommerce.ProductVariant.Version
    resource UniboExPoc.Ecommerce.ProductCategory
    resource UniboExPoc.Ecommerce.ProductCategory.Version
    resource UniboExPoc.Ecommerce.ProductPrice
    resource UniboExPoc.Ecommerce.ProductPrice.Version
    resource UniboExPoc.Ecommerce.Catalog
    resource UniboExPoc.Ecommerce.Catalog.Version
    resource UniboExPoc.Ecommerce.WebSite
    resource UniboExPoc.Ecommerce.Theme
    resource UniboExPoc.Ecommerce.Theme.Version
    resource UniboExPoc.Ecommerce.ShoppingCart
    resource UniboExPoc.Ecommerce.ShoppingCart.Version
    resource UniboExPoc.Ecommerce.LoyaltyProgram
    resource UniboExPoc.Ecommerce.LoyaltyProgram.Version
    resource UniboExPoc.Ecommerce.LoyaltyRule
    resource UniboExPoc.Ecommerce.LoyaltyRule.Version
    resource UniboExPoc.Ecommerce.LoyaltyReward
    resource UniboExPoc.Ecommerce.LoyaltyReward.Version
    resource UniboExPoc.Ecommerce.LoyaltyCard
    resource UniboExPoc.Ecommerce.LoyaltyCard.Version
    resource UniboExPoc.Ecommerce.UOM
    resource UniboExPoc.Ecommerce.Ribbon
    resource UniboExPoc.Ecommerce.Pricelist
    resource UniboExPoc.Ecommerce.MailTemplate
    resource UniboExPoc.Ecommerce.DeliveryCarrier
    resource UniboExPoc.Ecommerce.ProductTemplatePublicCategoryLink
    resource UniboExPoc.Ecommerce.ProductTemplateAlternativeLink
    resource UniboExPoc.Ecommerce.ProductTemplateAccessoryLink
    resource UniboExPoc.Ecommerce.TravelCity
    resource UniboExPoc.Ecommerce.TravelCity.Version
    resource UniboExPoc.Ecommerce.TravelAirport
    resource UniboExPoc.Ecommerce.TravelAirport.Version
    resource UniboExPoc.Ecommerce.TravelStation
    resource UniboExPoc.Ecommerce.TravelStation.Version
    resource UniboExPoc.Ecommerce.Party
  end
end
