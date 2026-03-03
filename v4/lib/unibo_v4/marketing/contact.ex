defmodule UniboV4.Marketing.Contact do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_contacts"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_contact

    queries do
      get :get_marketing_contact, :read
      list :list_marketing_contacts, :read
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
