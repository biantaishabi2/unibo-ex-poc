defmodule UniboV4.Maintenance.VehicleTagLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "maintenance_vehicle_tag_links"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
