defmodule UniboV4.Communication.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "communication_users"
    repo UniboV4.Repo
  end

  graphql do
    type :communication_user

    queries do
      get :get_communication_user, :read
      list :list_communication_users, :read
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
