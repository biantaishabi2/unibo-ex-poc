# Workflow: event_type_lifecycle — 活动类型管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Events.EventType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Events,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "events_event_types"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :parent_type_id, :uuid, public?: true
    attribute :code, :string do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :events, UniboV4.Events.Event do
      public? true
      destination_attribute :event_type_id
    end
    has_many :children, UniboV4.Events.EventType do
      public? true
      destination_attribute :parent_type_id
    end
    has_many :translations, UniboV4.Events.EventTypeTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :code, :parent_type_id]
      validate present(:name)
      validate present(:code)
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
      accept [:name, :parent_type_id]
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
