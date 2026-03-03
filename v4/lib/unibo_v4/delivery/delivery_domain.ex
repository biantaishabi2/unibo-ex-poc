defmodule UniboV4.Delivery do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Delivery.Delivery
    resource UniboV4.Delivery.Shipment
    resource UniboV4.Delivery.ShipmentType
    resource UniboV4.Delivery.ShipmentMethodType
    resource UniboV4.Delivery.CarrierShipmentMethod
    resource UniboV4.Delivery.ShipmentRouteSegment
    resource UniboV4.Delivery.ShipmentCostEstimate
    resource UniboV4.Delivery.ShipmentItem
    resource UniboV4.Delivery.ShipmentPackage
    resource UniboV4.Delivery.ShipmentBoxType
    resource UniboV4.Delivery.ShipmentPackageContent
    resource UniboV4.Delivery.ShipmentPackageRouteSeg
    resource UniboV4.Delivery.ShipmentStatus
    resource UniboV4.Delivery.Party
    resource UniboV4.Delivery.Facility
    resource UniboV4.Delivery.FixedAsset
    resource UniboV4.Delivery.Product
  end
end
