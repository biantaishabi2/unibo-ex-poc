defmodule UniboV4.Sign.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sign,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "sign_users"
    repo UniboV4.Repo
  end

  graphql do
    type :sign_user

    queries do
      get :get_sign_user, :read
      list :list_sign_users, :read
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
