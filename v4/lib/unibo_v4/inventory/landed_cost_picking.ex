defmodule UniboV4.Inventory.LandedCostPicking do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "inventory_landed_cost_pickings"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_landed_cost_picking

    queries do
      get :get_inventory_landed_cost_picking, :read
      list :list_inventory_landed_cost_pickings, :read
    end

    mutations do
      create :create_inventory_landed_cost_picking, :create
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :landed_cost, UniboV4.Inventory.LandedCost do
      public? true
      allow_nil? false
    end
    belongs_to :picking, UniboV4.Inventory.StockPicking do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept []
      argument :landed_cost_id, :uuid, allow_nil?: false
      argument :picking_id, :uuid, allow_nil?: false
      change manage_relationship(:landed_cost_id, :landed_cost, type: :append, on_lookup: :relate)
      change manage_relationship(:picking_id, :picking, type: :append, on_lookup: :relate)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

end
