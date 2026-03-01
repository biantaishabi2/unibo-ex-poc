defmodule UniboV4.Accounting.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "accounting_users"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_user

    queries do
      get :get_accounting_user, :read
      list :list_accounting_users, :read
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
