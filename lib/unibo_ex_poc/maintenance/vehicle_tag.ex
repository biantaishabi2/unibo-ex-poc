defmodule UniboV4.Maintenance.VehicleTag do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "车辆标签占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "maintenance_vehicle_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_vehicle_tag

    queries do
      get :get_maintenance_vehicle_tag, :read
      list :list_maintenance_vehicle_tags, :read
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
