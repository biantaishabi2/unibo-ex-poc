# Workflow: fleet_vehicle_type_lifecycle — 车队车辆类型维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Fleet.FleetVehicleType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "fleet_vehicle_types"
    repo UniboV4.Repo
  end

  graphql do
    type :fleet_fleet_vehicle_type

    queries do
      get :get_fleet_fleet_vehicle_type, :read
      list :list_fleet_fleet_vehicle_types, :read
    end

    mutations do
      create :create_fleet_fleet_vehicle_type, :create
      update :update_fleet_fleet_vehicle_type, :update
      destroy :delete_fleet_fleet_vehicle_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :parent_type_id, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :vehicles, UniboV4.Fleet.FleetVehicle do
      public? true
      destination_attribute :fleet_vehicle_type_id
    end
    has_many :translations, UniboV4.Fleet.FleetVehicleTypeTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :parent_type_id]
      validate present(:name)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :description, :parent_type_id]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

end
