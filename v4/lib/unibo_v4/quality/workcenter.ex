defmodule UniboV4.Quality.Workcenter do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "quality_workcenters"
    repo UniboV4.Repo
  end

  graphql do
    type :quality_workcenter

    queries do
      get :get_quality_workcenter, :read
      list :list_quality_workcenters, :read
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
