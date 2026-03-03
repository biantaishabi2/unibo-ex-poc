defmodule UniboV4.Knowledge.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "knowledge_users"
    repo UniboV4.Repo
  end

  graphql do
    type :knowledge_user

    queries do
      get :get_knowledge_user, :read
      list :list_knowledge_users, :read
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
