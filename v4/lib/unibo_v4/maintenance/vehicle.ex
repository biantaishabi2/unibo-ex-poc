defmodule UniboV4.Maintenance.Vehicle do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "vehicles"
    repo UniboV4.Repo
  end

  graphql do
    type :vehicle

    queries do
      get :get_vehicle, :read
      list :list_vehicles, :read
    end

    mutations do
      create :create_vehicle, :create
      update :update_vehicle, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :vehicle_code, :string, allow_nil?: false
    attribute :plate_number, :string, allow_nil?: false
    attribute :brand, :string
    attribute :model, :string
    attribute :year, :integer
    attribute :status, :atom do
      constraints one_of: [:available, :in_use, :maintenance, :retired]
      default :available
    end
    attribute :odometer, :decimal, default: 0
    attribute :fuel_type, :atom, constraints: [one_of: [:gasoline, :diesel, :electric, :hybrid]]
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:vehicle_code, :plate_number, :brand, :model, :year, :fuel_type, :notes]
      validate present(:vehicle_code)
      validate present(:plate_number)
    end
    update :update do
      primary? true
      accept [:plate_number, :status, :odometer, :notes]
    end
  end

  identities do
    identity :unique_vehicle_code, [:vehicle_code]
  end

end
