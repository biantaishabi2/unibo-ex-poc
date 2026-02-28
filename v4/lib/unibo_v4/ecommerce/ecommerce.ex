defmodule UniboV4.Ecommerce do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Ecommerce.ProductTemplate
    resource UniboV4.Ecommerce.ProductVariant
    resource UniboV4.Ecommerce.ProductCategory
    resource UniboV4.Ecommerce.ProductPrice
    resource UniboV4.Ecommerce.Catalog
    resource UniboV4.Ecommerce.WebSite
    resource UniboV4.Ecommerce.ShoppingCart
  end
end
