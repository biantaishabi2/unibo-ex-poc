defmodule UniboV4.Subscriptions.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "subscriptions_users"
    repo UniboV4.Repo
  end

  graphql do
    type :subscriptions_user

    queries do
      get :get_subscriptions_user, :read
      list :list_subscriptions_users, :read
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
