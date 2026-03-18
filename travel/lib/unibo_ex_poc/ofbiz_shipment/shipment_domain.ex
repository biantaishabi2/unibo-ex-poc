defmodule UniboExPoc.Ofbiz.Shipment do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Shipment.Picklist
    resource UniboExPoc.Ofbiz.Shipment.PicklistBin
    resource UniboExPoc.Ofbiz.Shipment.CarrierShipmentMethod
    resource UniboExPoc.Ofbiz.Shipment.Delivery
    resource UniboExPoc.Ofbiz.Shipment.Shipment
    resource UniboExPoc.Ofbiz.Shipment.ShipmentBoxType
    resource UniboExPoc.Ofbiz.Shipment.ShipmentCostEstimate
    resource UniboExPoc.Ofbiz.Shipment.ShipmentItem
    resource UniboExPoc.Ofbiz.Shipment.ShipmentMethodType
    resource UniboExPoc.Ofbiz.Shipment.ShipmentPackage
    resource UniboExPoc.Ofbiz.Shipment.ShipmentPackageContent
    resource UniboExPoc.Ofbiz.Shipment.ShipmentPackageRouteSeg
    resource UniboExPoc.Ofbiz.Shipment.ShipmentRouteSegment
    resource UniboExPoc.Ofbiz.Shipment.ShipmentStatus
    resource UniboExPoc.Ofbiz.Shipment.ShipmentType
    resource UniboExPoc.Ofbiz.Shipment.ContactMech
    resource UniboExPoc.Ofbiz.Shipment.Facility
    resource UniboExPoc.Ofbiz.Shipment.FixedAsset
    resource UniboExPoc.Ofbiz.Shipment.Geo
    resource UniboExPoc.Ofbiz.Shipment.OrderHeader
    resource UniboExPoc.Ofbiz.Shipment.Party
    resource UniboExPoc.Ofbiz.Shipment.Product
    resource UniboExPoc.Ofbiz.Shipment.ProductStoreShipmentMeth
    resource UniboExPoc.Ofbiz.Shipment.QuantityBreak
    resource UniboExPoc.Ofbiz.Shipment.ReturnHeader
    resource UniboExPoc.Ofbiz.Shipment.RoleType
    resource UniboExPoc.Ofbiz.Shipment.StatusItem
    resource UniboExPoc.Ofbiz.Shipment.TelecomNumber
    resource UniboExPoc.Ofbiz.Shipment.Uom
    resource UniboExPoc.Ofbiz.Shipment.UserLogin
    resource UniboExPoc.Ofbiz.Shipment.WorkEffort
  end
end
