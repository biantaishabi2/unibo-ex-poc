defmodule UniboV4.Inventory.Lot do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "lots"
    repo UniboV4.Repo
  end

  graphql do
    type :lot

    queries do
      get :get_lot, :read
      list :list_lots, :read
    end

    mutations do
      create :create_lot, :create
      update :update_lot, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :lot_number, :string, allow_nil?: false
    attribute :product_code, :string, allow_nil?: false
    attribute :expiration_date, :date
    attribute :manufacturing_date, :date
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:lot_number, :product_code, :expiration_date, :manufacturing_date, :notes]
      validate present(:lot_number)
      validate present(:product_code)
    end
    update :update do
      primary? true
      accept [:expiration_date, :notes]
    end
  end

  identities do
    identity :unique_lot_number, [:lot_number]
  end

end
