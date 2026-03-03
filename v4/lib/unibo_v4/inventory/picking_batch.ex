defmodule UniboV4.Inventory.PickingBatch do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "inventory_picking_batches"
    repo UniboV4.Repo
  end

  graphql do
    type :inventory_picking_batch

    queries do
      get :get_inventory_picking_batch, :read
      list :list_inventory_picking_batchs, :read
    end

    mutations do
      create :create_inventory_picking_batch, :create
      update :update_inventory_picking_batch, :update
      update :action_confirm_inventory_picking_batch, :action_confirm
      update :action_done_inventory_picking_batch, :action_done
      update :action_cancel_inventory_picking_batch, :action_cancel
      update :action_assign_inventory_picking_batch, :action_assign
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :in_progress, :done, :cancel]
      default :draft
      public? true
    end
    attribute :scheduled_date, :utc_datetime, public?: true
    attribute :is_wave, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :picking_ids, UniboV4.Inventory.StockPicking do
      public? true
      destination_attribute :batch_id
    end
    belongs_to :responsible, UniboV4.Inventory.Partner do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :is_wave]
      argument :responsible_id, :uuid
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
      accept [:is_wave]
      argument :responsible_id, :uuid
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
    update :action_confirm do
      accept []
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
    update :action_done do
      accept []
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
    update :action_cancel do
      accept []
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
    update :action_assign do
      accept []
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
