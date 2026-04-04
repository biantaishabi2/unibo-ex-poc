defmodule Travel.Travel do
  use Ash.Domain,
    extensions: [AshGraphql.Domain],
    validate_config_inclusion?: false

  graphql do
    authorize? false
  end

  resources do
    resource Travel.Travel.TravelHotel
    resource Travel.Travel.TravelHotel.Version
    resource Travel.Travel.TravelRoomType
    resource Travel.Travel.TravelRoomType.Version
    resource Travel.Travel.TravelAirline
    resource Travel.Travel.TravelAirline.Version
    resource Travel.Travel.TravelCabinClass
    resource Travel.Travel.TravelCabinClass.Version
    resource Travel.Travel.TravelStaticCodeMapping
    resource Travel.Travel.TravelStaticCodeMapping.Version
    resource Travel.Travel.HotelOffer
    resource Travel.Travel.HotelOffer.Version
    resource Travel.Travel.FlightOffer
    resource Travel.Travel.FlightOffer.Version
    resource Travel.Travel.VacationOffer
    resource Travel.Travel.VacationOffer.Version
    resource Travel.Travel.TrainOffer
    resource Travel.Travel.TrainOffer.Version
    resource Travel.Travel.TravelOrder
    resource Travel.Travel.TravelOrder.Version
    resource Travel.Travel.TravelFulfillment
    resource Travel.Travel.TravelFulfillment.Version
    resource Travel.Travel.TravelChangeOrder
    resource Travel.Travel.TravelChangeOrder.Version
    resource Travel.Travel.TravelRefundOrder
    resource Travel.Travel.TravelRefundOrder.Version
    resource Travel.Travel.TravelPolicy
    resource Travel.Travel.TravelPolicy.Version
    resource Travel.Travel.TravelPolicyCheck
    resource Travel.Travel.TravelPolicyCheck.Version
  end
end
