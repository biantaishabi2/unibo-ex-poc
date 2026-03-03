defmodule UniboV4.Analytic.Partner do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "analytic_partners"
    repo UniboV4.Repo
  end

  graphql do
    type :analytic_partner

    queries do
      get :get_analytic_partner, :read
      list :list_analytic_partners, :read
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
