defmodule UniboExPoc.Travel do
  use Ash.Domain,
    extensions: [AshGraphql.Domain],
    validate_config_inclusion?: false

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Travel.TravelHotel
    resource UniboExPoc.Travel.TravelRoomType
    resource UniboExPoc.Travel.TravelAirline
    resource UniboExPoc.Travel.TravelCabinClass
    resource UniboExPoc.Travel.TravelStaticCodeMapping
    resource UniboExPoc.Travel.HotelOffer
    resource UniboExPoc.Travel.FlightOffer
    resource UniboExPoc.Travel.VacationOffer
    resource UniboExPoc.Travel.TrainOffer
    resource UniboExPoc.Travel.TravelOrder
    resource UniboExPoc.Travel.TravelFulfillment
    resource UniboExPoc.Travel.TravelChangeOrder
    resource UniboExPoc.Travel.TravelRefundOrder
    resource UniboExPoc.Travel.TravelPolicy
    resource UniboExPoc.Travel.TravelPolicyCheck
  end
end
