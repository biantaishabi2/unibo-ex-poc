defmodule UniboV4.ELearning.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.ELearning,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "e_learning_users"
    repo UniboV4.Repo
  end

  graphql do
    type :e_learning_user

    queries do
      get :get_e_learning_user, :read
      list :list_e_learning_users, :read
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
