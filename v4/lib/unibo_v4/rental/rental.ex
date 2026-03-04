defmodule UniboV4.Rental do
  use Ash.Domain

  resources do
    resource UniboV4.Rental.RentalOrder
    resource UniboV4.Rental.RentalOrderLine
    resource UniboV4.Rental.RentalPricing
    resource UniboV4.Rental.RentalPenalty
    resource UniboV4.Rental.User
    resource UniboV4.Rental.Customer
    resource UniboV4.Rental.Product
    resource UniboV4.Rental.ProductTemplate
    resource UniboV4.Rental.Pricelist
  end
end
