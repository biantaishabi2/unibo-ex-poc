defmodule UniboV4.Rental.Customer do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "rental_customers"
    repo UniboV4.Repo
  end

  graphql do
    type :rental_customer

    queries do
      get :get_rental_customer, :read
      list :list_rental_customers, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
