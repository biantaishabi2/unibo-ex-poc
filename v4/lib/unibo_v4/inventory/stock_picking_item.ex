defmodule UniboV4.Inventory.StockPickingItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "inventory_stock_picking_items"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_stock_picking_item

    mutations do
      create :create_inventory_stock_picking_item, :create
      update :update_inventory_stock_picking_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_code, :string, public?: true
    attribute :quantity_planned, :decimal do
      allow_nil? false
      public? true
    end
    attribute :quantity_done, :decimal do
      default 0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :picking, UniboV4.Inventory.StockPicking do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :product_code, :quantity_planned]
      argument :picking_id, :uuid, allow_nil?: false
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
    update :update do
      primary? true
      accept [:quantity_done]
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

  validations do
    validate compare(:quantity_planned, greater_than: 0)
    validate compare(:quantity_done, greater_than_or_equal_to: 0)
  end

end
