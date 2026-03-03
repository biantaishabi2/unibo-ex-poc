defmodule UniboV4.Quality.Company do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "quality_companies"
    repo UniboV4.Repo
  end

  graphql do
    type :quality_company

    queries do
      get :get_quality_company, :read
      list :list_quality_companys, :read
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
