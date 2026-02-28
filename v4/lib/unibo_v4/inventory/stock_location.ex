defmodule UniboV4.Inventory.StockLocation do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "stock_locations"
    repo UniboV4.Repo
  end

  graphql do
    type :stock_location

    queries do
      get :get_stock_location, :read
      list :list_stock_locations, :read
    end

    mutations do
      create :create_stock_location, :create
      update :update_stock_location, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :location_code, :string, allow_nil?: false
    attribute :area, :string
    attribute :aisle, :string
    attribute :section, :string
    attribute :level, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :warehouse, UniboV4.Inventory.Warehouse do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:location_code, :area, :aisle, :section, :level]
      argument :warehouse_id, :uuid, allow_nil?: false
      change manage_relationship(:warehouse_id, :warehouse, type: :append, on_lookup: :relate)
      validate present(:location_code)
    end
    update :update do
      primary? true
      accept [:area, :aisle, :section, :level]
    end
  end

end
