defmodule UniboExPoc.Delivery do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Delivery.Delivery
    resource UniboExPoc.Delivery.Delivery.Version
    resource UniboExPoc.Delivery.Shipment
    resource UniboExPoc.Delivery.Shipment.Version
    resource UniboExPoc.Delivery.CrossOrgTransaction
    resource UniboExPoc.Delivery.CrossOrgTransaction.Version
    resource UniboExPoc.Delivery.ShipmentType
    resource UniboExPoc.Delivery.ShipmentType.Version
    resource UniboExPoc.Delivery.ShipmentMethodType
    resource UniboExPoc.Delivery.ShipmentMethodType.Version
    resource UniboExPoc.Delivery.CarrierShipmentMethod
    resource UniboExPoc.Delivery.CarrierShipmentMethod.Version
    resource UniboExPoc.Delivery.ShipmentRouteSegment
    resource UniboExPoc.Delivery.ShipmentRouteSegment.Version
    resource UniboExPoc.Delivery.ShipmentCostEstimate
    resource UniboExPoc.Delivery.ShipmentCostEstimate.Version
    resource UniboExPoc.Delivery.ShipmentItem
    resource UniboExPoc.Delivery.ShipmentItem.Version
    resource UniboExPoc.Delivery.ShipmentPackage
    resource UniboExPoc.Delivery.ShipmentPackage.Version
    resource UniboExPoc.Delivery.ShipmentBoxType
    resource UniboExPoc.Delivery.ShipmentBoxType.Version
    resource UniboExPoc.Delivery.ShipmentPackageContent
    resource UniboExPoc.Delivery.ShipmentPackageContent.Version
    resource UniboExPoc.Delivery.ShipmentPackageRouteSeg
    resource UniboExPoc.Delivery.ShipmentPackageRouteSeg.Version
    resource UniboExPoc.Delivery.ShipmentStatus
    resource UniboExPoc.Delivery.Party
    resource UniboExPoc.Delivery.Facility
    resource UniboExPoc.Delivery.FixedAsset
    resource UniboExPoc.Delivery.Product
  end
end
