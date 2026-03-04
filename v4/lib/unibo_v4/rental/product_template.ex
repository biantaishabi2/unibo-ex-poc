defmodule UniboV4.Rental.ProductTemplate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rental,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "rental_product_templates"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read]
  end

end
