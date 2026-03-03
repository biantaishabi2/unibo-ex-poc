defmodule UniboV4.Documents.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "documents_users"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_user

    queries do
      get :get_documents_user, :read
      list :list_documents_users, :read
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
