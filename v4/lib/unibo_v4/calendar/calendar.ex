# Workflow: calendar_container_lifecycle_flow — 日历容器维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Calendar.Calendar do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Calendar,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "calendar_calendars"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :color, :integer do
      default 0
      public? true
    end
    attribute :owner_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :calendar_type, :atom do
      allow_nil? false
      constraints one_of: [:personal, :team, :resource]
      default :personal
      public? true
    end
    attribute :is_default, :boolean do
      default false
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :events, UniboV4.Calendar.CalendarEvent do
      public? true
      destination_attribute :calendar_id
    end
    has_many :translations, UniboV4.Calendar.CalendarTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :color, :owner_id, :calendar_type, :is_default, :active]
      validate present(:name)
      validate present(:owner_id)
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
      accept [:name, :description, :color, :calendar_type, :is_default, :active]
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
