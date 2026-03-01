defmodule UniboV4.Inventory.StockLocation do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "inventory_stock_locations"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_stock_location

    queries do
      get :get_inventory_stock_location, :read
      list :list_inventory_stock_locations, :read
    end

    mutations do
      create :create_inventory_stock_location, :create
      update :update_inventory_stock_location, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :complete_name, :string, public?: true
    attribute :location_code, :string do
      allow_nil? false
      public? true
    end
    attribute :usage, :atom do
      allow_nil? false
      constraints one_of: [:internal, :supplier, :customer, :inventory, :transit, :production, :view]
      public? true
    end
    attribute :area, :string, public?: true
    attribute :aisle, :string, public?: true
    attribute :section, :string, public?: true
    attribute :level, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :warehouse, UniboV4.Inventory.Warehouse do
      public? true
      allow_nil? false
    end
    belongs_to :parent_location, UniboV4.Inventory.StockLocation do
      public? true
    end
    has_many :child_locations, UniboV4.Inventory.StockLocation do
      public? true
      destination_attribute :parent_location_id
    end
    belongs_to :removal_strategy, UniboV4.Inventory.RemovalStrategy do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :location_code, :usage, :area, :aisle, :section, :level]
      argument :warehouse_id, :uuid, allow_nil?: false
      argument :parent_location_id, :uuid
      change manage_relationship(:warehouse_id, :warehouse, type: :append, on_lookup: :relate)
      validate present(:location_code)
      validate present(:name)
      validate present(:usage)
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
      accept [:name, :area, :aisle, :section, :level, :usage]
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
