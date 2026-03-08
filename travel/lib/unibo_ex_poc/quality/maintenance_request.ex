defmodule UniboExPoc.Quality.MaintenanceRequest do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "维保请求占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "quality_maintenance_requests"
    repo UniboExPoc.Repo
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
