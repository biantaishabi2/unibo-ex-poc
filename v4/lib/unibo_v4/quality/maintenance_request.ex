defmodule UniboV4.Quality.MaintenanceRequest do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "quality_maintenance_requests"
    repo UniboV4.Repo
  end

  graphql do
    type :quality_maintenance_request

    queries do
      get :get_quality_maintenance_request, :read
      list :list_quality_maintenance_requests, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :request_number, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
