defmodule UniboV4.Ecommerce do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Ecommerce.ProductTemplate
    resource UniboV4.Ecommerce.ProductTemplateTranslation
    resource UniboV4.Ecommerce.ProductVariant
    resource UniboV4.Ecommerce.ProductCategory
    resource UniboV4.Ecommerce.ProductPrice
    resource UniboV4.Ecommerce.Catalog
    resource UniboV4.Ecommerce.WebSite
    resource UniboV4.Ecommerce.WebPage
    resource UniboV4.Ecommerce.Menu
    resource UniboV4.Ecommerce.MenuTranslation
    resource UniboV4.Ecommerce.Theme
    resource UniboV4.Ecommerce.ShoppingCart
    resource UniboV4.Ecommerce.LoyaltyProgram
    resource UniboV4.Ecommerce.LoyaltyRule
    resource UniboV4.Ecommerce.LoyaltyReward
    resource UniboV4.Ecommerce.LoyaltyCard
    resource UniboV4.Ecommerce.User
    resource UniboV4.Ecommerce.Company
    resource UniboV4.Ecommerce.UOM
    resource UniboV4.Ecommerce.Ribbon
    resource UniboV4.Ecommerce.Pricelist
    resource UniboV4.Ecommerce.MailTemplate
    resource UniboV4.Ecommerce.DeliveryCarrier
    resource UniboV4.Ecommerce.ProductTemplatePublicCategoryLink
    resource UniboV4.Ecommerce.ProductTemplateAlternativeLink
    resource UniboV4.Ecommerce.ProductTemplateAccessoryLink
  end
end
