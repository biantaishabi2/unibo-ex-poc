defmodule UniboV4.Marketing.Company do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_companies"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_company

    queries do
      get :get_marketing_company, :read
      list :list_marketing_companys, :read
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
