defmodule UniboV4.Inventory.Partner do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "inventory_partners"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_partner

    queries do
      get :get_inventory_partner, :read
      list :list_inventory_partners, :read
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
