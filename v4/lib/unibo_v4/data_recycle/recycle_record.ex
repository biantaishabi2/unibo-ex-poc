# Workflow: recycle_record_processing — 待回收记录处理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> validate
#   create --> discard
#   validate --> [*]
#   discard --> [*]
# ```
defmodule UniboV4.DataRecycle.RecycleRecord do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.DataRecycle,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "data_recycle_recycle_records"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :res_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :res_model_name, :string, public?: true
    attribute :name, :string, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :recycle_model, UniboV4.DataRecycle.RecycleModel do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:res_id, :res_model_name, :name, :active]
      argument :recycle_model_id, :uuid, allow_nil?: false
      change manage_relationship(:recycle_model_id, :recycle_model, type: :append, on_lookup: :relate)
      validate present(:res_id)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :validate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "仅活跃待回收记录可执行确认或忽略"
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
    update :discard do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "仅活跃待回收记录可执行确认或忽略"
      change set_attribute(:active, false)
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
