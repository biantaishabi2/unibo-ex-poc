# Workflow: picking_batch_lifecycle_flow — 批量拣货正常流转流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   action_confirm --> [*]
#   action_assign --> [*]
#   action_done --> [*]
# ```
# Workflow: picking_batch_cancel_flow — 批量拣货取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_confirm --> [*]
#   action_cancel --> [*]
# ```
defmodule UniboV4.Inventory.PickingBatch do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "inventory_picking_batches"
    repo UniboV4.Repo
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
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中状态可以验证"
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
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :in_progress]}))
        end
      end
      # message: "只有草稿或进行中状态可以取消"
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
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中状态可以检查可用性"
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
