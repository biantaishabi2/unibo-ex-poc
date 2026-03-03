defmodule UniboV4.Maintenance.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "maintenance_users"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_user

    queries do
      get :get_maintenance_user, :read
      list :list_maintenance_users, :read
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
