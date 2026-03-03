defmodule UniboV4.Rental.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "rental_users"
    repo UniboV4.Repo
  end

  graphql do
    type :rental_user

    queries do
      get :get_rental_user, :read
      list :list_rental_users, :read
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
