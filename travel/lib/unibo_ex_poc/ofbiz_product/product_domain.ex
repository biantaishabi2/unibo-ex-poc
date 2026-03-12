defmodule UniboExPoc.Ofbiz.Product do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Product.ProductCategory
<<<<<<< Updated upstream
    resource UniboExPoc.Ofbiz.Product.ProductCategoryType
    resource UniboExPoc.Ofbiz.Product.Facility
    resource UniboExPoc.Ofbiz.Product.FacilityGroup
    resource UniboExPoc.Ofbiz.Product.FacilityGroupType
    resource UniboExPoc.Ofbiz.Product.FacilityType
=======
    resource UniboExPoc.Ofbiz.Product.ProductCategory.Version
    resource UniboExPoc.Ofbiz.Product.ProductCategoryType
    resource UniboExPoc.Ofbiz.Product.ProductCategoryType.Version
    resource UniboExPoc.Ofbiz.Product.Facility
    resource UniboExPoc.Ofbiz.Product.Facility.Version
    resource UniboExPoc.Ofbiz.Product.FacilityGroup
    resource UniboExPoc.Ofbiz.Product.FacilityGroup.Version
    resource UniboExPoc.Ofbiz.Product.FacilityGroupType
    resource UniboExPoc.Ofbiz.Product.FacilityGroupType.Version
    resource UniboExPoc.Ofbiz.Product.FacilityType
    resource UniboExPoc.Ofbiz.Product.FacilityType.Version
>>>>>>> Stashed changes
    resource UniboExPoc.Ofbiz.Product.ProductFeature
    resource UniboExPoc.Ofbiz.Product.ProductFeatureAppl
    resource UniboExPoc.Ofbiz.Product.ProductFeatureApplType
<<<<<<< Updated upstream
    resource UniboExPoc.Ofbiz.Product.ProductFeatureCategory
    resource UniboExPoc.Ofbiz.Product.ProductFeatureType
    resource UniboExPoc.Ofbiz.Product.InventoryItemType
    resource UniboExPoc.Ofbiz.Product.Product
    resource UniboExPoc.Ofbiz.Product.ProductType
    resource UniboExPoc.Ofbiz.Product.ProductStore
    resource UniboExPoc.Ofbiz.Product.ProductStoreGroup
    resource UniboExPoc.Ofbiz.Product.ProductStoreGroupType
    resource UniboExPoc.Ofbiz.Product.SupplierPrefOrder
    resource UniboExPoc.Ofbiz.Product.SupplierProduct
    resource UniboExPoc.Ofbiz.Product.SupplierRatingType
=======
    resource UniboExPoc.Ofbiz.Product.ProductFeatureApplType.Version
    resource UniboExPoc.Ofbiz.Product.ProductFeatureCategory
    resource UniboExPoc.Ofbiz.Product.ProductFeatureCategory.Version
    resource UniboExPoc.Ofbiz.Product.ProductFeatureType
    resource UniboExPoc.Ofbiz.Product.ProductFeatureType.Version
    resource UniboExPoc.Ofbiz.Product.InventoryItemType
    resource UniboExPoc.Ofbiz.Product.InventoryItemType.Version
    resource UniboExPoc.Ofbiz.Product.Product
    resource UniboExPoc.Ofbiz.Product.Product.Version
    resource UniboExPoc.Ofbiz.Product.ProductType
    resource UniboExPoc.Ofbiz.Product.ProductType.Version
    resource UniboExPoc.Ofbiz.Product.ProductStore
    resource UniboExPoc.Ofbiz.Product.ProductStore.Version
    resource UniboExPoc.Ofbiz.Product.ProductStoreGroup
    resource UniboExPoc.Ofbiz.Product.ProductStoreGroup.Version
    resource UniboExPoc.Ofbiz.Product.ProductStoreGroupType
    resource UniboExPoc.Ofbiz.Product.ProductStoreGroupType.Version
>>>>>>> Stashed changes
  end
end
