defmodule UniboV4.Delivery.Delivery do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Delivery.Delivery.Delivery
    resource UniboV4.Delivery.Delivery.Shipment
    resource UniboV4.Delivery.Delivery.ShipmentType
    resource UniboV4.Delivery.Delivery.ShipmentMethodType
    resource UniboV4.Delivery.Delivery.CarrierShipmentMethod
    resource UniboV4.Delivery.Delivery.ShipmentRouteSegment
    resource UniboV4.Delivery.Delivery.ShipmentCostEstimate
    resource UniboV4.Delivery.Delivery.ShipmentItem
    resource UniboV4.Delivery.Delivery.ShipmentPackage
    resource UniboV4.Delivery.Delivery.ShipmentBoxType
    resource UniboV4.Delivery.Delivery.ShipmentPackageContent
    resource UniboV4.Delivery.Delivery.ShipmentPackageRouteSeg
    resource UniboV4.Delivery.Delivery.ShipmentStatus
    resource UniboV4.Delivery.Delivery.Party
    resource UniboV4.Delivery.Delivery.Facility
    resource UniboV4.Delivery.Delivery.FixedAsset
    resource UniboV4.Delivery.Delivery.Product
  end
end
