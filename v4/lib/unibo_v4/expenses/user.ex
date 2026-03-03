defmodule UniboV4.Expenses.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "expenses_users"
    repo UniboV4.Repo
  end

  graphql do
    type :expenses_user

    queries do
      get :get_expenses_user, :read
      list :list_expenses_users, :read
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
