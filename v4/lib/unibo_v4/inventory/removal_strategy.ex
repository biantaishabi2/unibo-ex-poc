defmodule UniboV4.Inventory.RemovalStrategy do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "inventory_removal_strategies"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_removal_strategy

    queries do
      get :get_inventory_removal_strategy, :read
      list :list_inventory_removal_strategys, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:name]
    end
  end

end
