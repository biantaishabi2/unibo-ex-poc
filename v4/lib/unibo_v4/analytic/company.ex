defmodule UniboV4.Analytic.Analytic.Company do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Analytic.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "analytic_companies"
    repo UniboV4.Repo
  end

  graphql do
    type :analytic_company

    queries do
      get :get_analytic_company, :read
      list :list_analytic_companys, :read
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
