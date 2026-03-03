defmodule UniboV4.Approvals.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "approvals_users"
    repo UniboV4.Repo
  end

  graphql do
    type :approvals_user

    queries do
      get :get_approvals_user, :read
      list :list_approvals_users, :read
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
