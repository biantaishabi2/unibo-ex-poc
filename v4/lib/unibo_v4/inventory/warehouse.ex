defmodule UniboV4.Inventory.Warehouse do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "warehouses"
    repo UniboV4.Repo
  end

  graphql do
    type :warehouse

    queries do
      get :get_warehouse, :read
      list :list_warehouses, :read
    end

    mutations do
      create :create_warehouse, :create
      update :update_warehouse, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :warehouse_code, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:active, :inactive]
      default :active
    end
    attribute :address, :string
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :locations, UniboV4.Inventory.StockLocation
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:warehouse_code, :name, :address, :description]
      validate present(:warehouse_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :address, :description, :status]
    end
  end

  identities do
    identity :unique_warehouse_code, [:warehouse_code]
  end

end
