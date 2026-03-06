defmodule UniboExPoc.Travel.Travel do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Travel.Travel.HotelOffer
    resource UniboExPoc.Travel.Travel.FlightOffer
    resource UniboExPoc.Travel.Travel.VacationOffer
    resource UniboExPoc.Travel.Travel.TravelOrder
    resource UniboExPoc.Travel.Travel.TravelFulfillment
  end
end
