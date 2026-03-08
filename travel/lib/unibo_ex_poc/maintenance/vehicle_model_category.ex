defmodule UniboExPoc.Maintenance.VehicleModelCategory do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "车型分类占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "maintenance_vehicle_model_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_vehicle_model_category

    queries do
      get :get_maintenance_vehicle_model_category, :read
      list :list_maintenance_vehicle_model_categorys, :read
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
