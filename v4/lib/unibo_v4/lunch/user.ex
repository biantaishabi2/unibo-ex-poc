defmodule UniboV4.Lunch.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "lunch_users"
    repo UniboV4.Repo
  end

  graphql do
    type :lunch_user

    queries do
      get :get_lunch_user, :read
      list :list_lunch_users, :read
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
