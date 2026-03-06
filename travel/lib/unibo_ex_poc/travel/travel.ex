defmodule UniboExPoc.Travel do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
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
