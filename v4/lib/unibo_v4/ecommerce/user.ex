defmodule UniboV4.Ecommerce.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "ecommerce_users"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_user

    queries do
      get :get_ecommerce_user, :read
      list :list_ecommerce_users, :read
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
