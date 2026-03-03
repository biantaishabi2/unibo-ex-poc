defmodule UniboV4.Studio.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Studio,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "studio_users"
    repo UniboV4.Repo
  end

  graphql do
    type :studio_user

    queries do
      get :get_studio_user, :read
      list :list_studio_users, :read
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
