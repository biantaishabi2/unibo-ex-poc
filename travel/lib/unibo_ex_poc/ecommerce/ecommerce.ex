defmodule UniboExPoc.Ecommerce do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ecommerce.TravelCity
    resource UniboExPoc.Ecommerce.TravelCity.Version
    resource UniboExPoc.Ecommerce.TravelAirport
    resource UniboExPoc.Ecommerce.TravelAirport.Version
    resource UniboExPoc.Ecommerce.TravelStation
    resource UniboExPoc.Ecommerce.TravelStation.Version
  end
end
