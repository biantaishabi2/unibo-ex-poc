defmodule UniboV4.Rental do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Rental.RentalOrder
    resource UniboV4.Rental.RentalOrder.Version
    resource UniboV4.Rental.RentalOrderLine
    resource UniboV4.Rental.RentalOrderLine.Version
    resource UniboV4.Rental.RentalPricing
    resource UniboV4.Rental.RentalPricing.Version
    resource UniboV4.Rental.RentalPenalty
    resource UniboV4.Rental.RentalPenalty.Version
    resource UniboV4.Rental.Customer
    resource UniboV4.Rental.Product
    resource UniboV4.Rental.ProductTemplate
    resource UniboV4.Rental.Pricelist
    resource UniboV4.Rental.Party
  end
end
