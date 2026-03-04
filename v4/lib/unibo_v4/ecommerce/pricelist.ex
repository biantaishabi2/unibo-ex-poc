defmodule UniboV4.Ecommerce.Pricelist do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ecommerce_pricelists"
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
