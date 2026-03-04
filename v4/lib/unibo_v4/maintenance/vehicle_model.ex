# Workflow: vehicle_model_maintain_flow — 车辆模型维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Maintenance.VehicleModel do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "maintenance_vehicle_models"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :vehicle_type, :atom do
      constraints one_of: [:car, :bike]
      default :car
      public? true
    end
    attribute :transmission, :atom do
      constraints one_of: [:manual, :automatic, :cvt]
      public? true
    end
    attribute :model_year, :integer, public?: true
    attribute :electric_assistance, :boolean do
      default false
      public? true
    end
    attribute :color, :string, public?: true
    attribute :seats, :integer, public?: true
    attribute :doors, :integer, public?: true
    attribute :trailer_hook, :boolean do
      default false
      public? true
    end
    attribute :co2, :float, public?: true
    attribute :co2_standard, :string, public?: true
    attribute :fuel_type, :atom do
      constraints one_of: [:gasoline, :diesel, :electric, :hybrid, :hydrogen, :lpg, :cng]
      public? true
    end
    attribute :power, :integer, public?: true
    attribute :horsepower, :float, public?: true
    attribute :horsepower_tax, :float, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :brand, UniboV4.Maintenance.VehicleModelBrand do
      public? true
    end
    belongs_to :category, UniboV4.Maintenance.VehicleModelCategory do
      public? true
    end
    has_many :vehicles, UniboV4.Maintenance.Vehicle do
      public? true
      destination_attribute :model_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :vehicle_type, :transmission, :model_year, :electric_assistance, :color, :seats, :doors, :trailer_hook, :co2, :co2_standard, :fuel_type, :power, :horsepower, :horsepower_tax]
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
      accept [:name, :vehicle_type, :transmission, :model_year, :electric_assistance, :color, :seats, :doors, :trailer_hook, :co2, :co2_standard, :fuel_type, :power, :horsepower, :horsepower_tax]
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
