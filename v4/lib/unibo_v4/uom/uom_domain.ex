defmodule UniboV4.Uom do
  use Ash.Domain

  resources do
    resource UniboV4.Uom.UomCategory
    resource UniboV4.Uom.UomCategoryTranslation
    resource UniboV4.Uom.Uom
    resource UniboV4.Uom.UomTranslation
  end
end
