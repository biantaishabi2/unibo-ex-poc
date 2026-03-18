defmodule UniboExPoc.Ofbiz.Product do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Product.ProductCategory
    resource UniboExPoc.Ofbiz.Product.ProductCategoryType
    resource UniboExPoc.Ofbiz.Product.Facility
    resource UniboExPoc.Ofbiz.Product.FacilityGroup
    resource UniboExPoc.Ofbiz.Product.FacilityGroupType
    resource UniboExPoc.Ofbiz.Product.FacilityType
    resource UniboExPoc.Ofbiz.Product.ProductFeature
    resource UniboExPoc.Ofbiz.Product.ProductFeatureAppl
    resource UniboExPoc.Ofbiz.Product.ProductFeatureApplType
    resource UniboExPoc.Ofbiz.Product.ProductFeatureCategory
    resource UniboExPoc.Ofbiz.Product.ProductFeatureType
    resource UniboExPoc.Ofbiz.Product.InventoryItemType
    resource UniboExPoc.Ofbiz.Product.Product
    resource UniboExPoc.Ofbiz.Product.ProductType
    resource UniboExPoc.Ofbiz.Product.ProductStore
    resource UniboExPoc.Ofbiz.Product.ProductStoreGroup
    resource UniboExPoc.Ofbiz.Product.ProductStoreGroupType
  end
end
