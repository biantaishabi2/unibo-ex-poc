defmodule UniboExPoc.Travel do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Travel.TravelAirport
    resource UniboExPoc.Travel.TravelAirport.Version
    resource UniboExPoc.Travel.TravelStation
    resource UniboExPoc.Travel.TravelStation.Version
    resource UniboExPoc.Travel.TravelHotel
    resource UniboExPoc.Travel.TravelHotel.Version
    resource UniboExPoc.Travel.TravelRoomType
    resource UniboExPoc.Travel.TravelRoomType.Version
    resource UniboExPoc.Travel.TravelAirline
    resource UniboExPoc.Travel.TravelAirline.Version
    resource UniboExPoc.Travel.TravelCabinClass
    resource UniboExPoc.Travel.TravelCabinClass.Version
    resource UniboExPoc.Travel.TravelStaticCodeMapping
    resource UniboExPoc.Travel.TravelStaticCodeMapping.Version
    resource UniboExPoc.Travel.HotelOffer
    resource UniboExPoc.Travel.HotelOffer.Version
    resource UniboExPoc.Travel.FlightOffer
    resource UniboExPoc.Travel.FlightOffer.Version
    resource UniboExPoc.Travel.VacationOffer
    resource UniboExPoc.Travel.VacationOffer.Version
    resource UniboExPoc.Travel.TrainOffer
    resource UniboExPoc.Travel.TrainOffer.Version
    resource UniboExPoc.Travel.TravelOrder
    resource UniboExPoc.Travel.TravelOrder.Version
    resource UniboExPoc.Travel.TravelFulfillment
    resource UniboExPoc.Travel.TravelFulfillment.Version
  end
end
