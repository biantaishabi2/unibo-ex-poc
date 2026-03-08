defmodule UniboV4.Maintenance.VehicleTagLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "车辆-标签桥接占位实体"
  end

  postgres do
    table "maintenance_vehicle_tag_links"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_vehicle_tag_link

    queries do
      get :get_maintenance_vehicle_tag_link, :read
      list :list_maintenance_vehicle_tag_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :vehicle, UniboV4.Maintenance.Vehicle do
      public? true
      allow_nil? false
    end
    belongs_to :tag, UniboV4.Maintenance.VehicleTag do
      public? true
      allow_nil? false
      source_attribute :vehicle_tag_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
