defmodule UniboExPoc.Travel do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
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
    resource UniboExPoc.Travel.FlightOffer
    resource UniboExPoc.Travel.VacationOffer
    resource UniboExPoc.Travel.TrainOffer
    resource UniboExPoc.Travel.TravelOrder
    resource UniboExPoc.Travel.TravelFulfillment
  end
end
