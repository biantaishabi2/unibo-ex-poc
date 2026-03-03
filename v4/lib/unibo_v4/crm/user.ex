defmodule UniboV4.CRM.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "crm_users"
    repo UniboV4.Repo
  end

  graphql do
    type :crm_user

    queries do
      get :get_crm_user, :read
      list :list_crm_users, :read
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
