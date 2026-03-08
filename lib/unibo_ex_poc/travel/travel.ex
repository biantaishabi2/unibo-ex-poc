defmodule UniboV4.Travel do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Travel.TravelHotel
    resource UniboV4.Travel.TravelHotel.Version
    resource UniboV4.Travel.TravelRoomType
    resource UniboV4.Travel.TravelRoomType.Version
    resource UniboV4.Travel.TravelAirline
    resource UniboV4.Travel.TravelAirline.Version
    resource UniboV4.Travel.TravelCabinClass
    resource UniboV4.Travel.TravelCabinClass.Version
    resource UniboV4.Travel.TravelStaticCodeMapping
    resource UniboV4.Travel.TravelStaticCodeMapping.Version
    resource UniboV4.Travel.HotelOffer
    resource UniboV4.Travel.HotelOffer.Version
    resource UniboV4.Travel.FlightOffer
    resource UniboV4.Travel.FlightOffer.Version
    resource UniboV4.Travel.VacationOffer
    resource UniboV4.Travel.VacationOffer.Version
    resource UniboV4.Travel.TrainOffer
    resource UniboV4.Travel.TrainOffer.Version
    resource UniboV4.Travel.TravelOrder
    resource UniboV4.Travel.TravelOrder.Version
    resource UniboV4.Travel.TravelFulfillment
    resource UniboV4.Travel.TravelFulfillment.Version
  end
end
