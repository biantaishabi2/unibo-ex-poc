defmodule UniboExPoc.Uom do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Uom.UomCategory
    resource UniboExPoc.Uom.UomCategoryTranslation
    resource UniboExPoc.Uom.UomCategory.Version
    resource UniboExPoc.Uom.Uom
    resource UniboExPoc.Uom.UomTranslation
    resource UniboExPoc.Uom.Uom.Version
  end
end
