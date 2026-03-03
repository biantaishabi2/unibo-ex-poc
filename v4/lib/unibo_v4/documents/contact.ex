defmodule UniboV4.Documents.Contact do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "documents_contacts"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_contact

    queries do
      get :get_documents_contact, :read
      list :list_documents_contacts, :read
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
