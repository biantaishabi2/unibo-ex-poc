defmodule UniboExPoc.Maintenance.VehicleTagLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "车辆-标签桥接占位实体"
  end

  postgres do
    table "maintenance_vehicle_tag_links"
    repo UniboExPoc.Repo
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
    belongs_to :vehicle, UniboExPoc.Maintenance.Vehicle do
      public? true
      allow_nil? false
    end
    belongs_to :tag, UniboExPoc.Maintenance.VehicleTag do
      public? true
      allow_nil? false
      source_attribute :vehicle_tag_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
