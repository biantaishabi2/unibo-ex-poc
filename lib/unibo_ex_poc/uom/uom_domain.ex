defmodule UniboV4.Uom do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Uom.UomCategory
    resource UniboV4.Uom.UomCategoryTranslation
    resource UniboV4.Uom.UomCategory.Version
    resource UniboV4.Uom.Uom
    resource UniboV4.Uom.UomTranslation
    resource UniboV4.Uom.Uom.Version
  end
end
