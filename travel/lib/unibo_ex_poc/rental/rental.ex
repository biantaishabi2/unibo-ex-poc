defmodule UniboExPoc.Rental do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Rental.RentalOrder
    resource UniboExPoc.Rental.RentalOrder.Version
    resource UniboExPoc.Rental.RentalOrderLine
    resource UniboExPoc.Rental.RentalOrderLine.Version
    resource UniboExPoc.Rental.RentalPricing
    resource UniboExPoc.Rental.RentalPricing.Version
    resource UniboExPoc.Rental.RentalPenalty
    resource UniboExPoc.Rental.RentalPenalty.Version
    resource UniboExPoc.Rental.Customer
    resource UniboExPoc.Rental.Product
    resource UniboExPoc.Rental.ProductTemplate
    resource UniboExPoc.Rental.Pricelist
    resource UniboExPoc.Rental.Party
  end
end
