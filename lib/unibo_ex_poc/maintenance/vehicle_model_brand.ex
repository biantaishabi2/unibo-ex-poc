defmodule UniboExPoc.Maintenance.VehicleModelBrand do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "车型品牌占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "maintenance_vehicle_model_brands"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_vehicle_model_brand

    queries do
      get :get_maintenance_vehicle_model_brand, :read
      list :list_maintenance_vehicle_model_brands, :read
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
