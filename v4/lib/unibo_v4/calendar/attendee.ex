# Workflow: attendee_response_flow — 参与者邀请与响应流程
# ```mermaid
# stateDiagram-v2
#   [*] --> invite
#   invite --> update_response
#   invite --> remove
#   update_response --> update_response
#   update_response --> remove
#   remove --> [*]
# ```
defmodule UniboV4.Calendar.Attendee do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Calendar,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "calendar_attendees"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :party_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :response_status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :accepted, :declined, :tentative]
      default :pending
      public? true
    end
    attribute :is_organizer, :boolean do
      default false
      public? true
    end
    attribute :role, :atom do
      constraints one_of: [:organizer, :required, :optional, :resource]
      default :required
      public? true
    end
    attribute :must_rsvp, :boolean do
      default false
      public? true
    end
    attribute :comments, :string, public?: true
    attribute :responded_at, :utc_datetime, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboV4.Calendar.CalendarEvent do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :invite do
      primary? true
      accept [:party_id, :role, :is_organizer, :must_rsvp, :comments]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:event_id)
      validate present(:party_id)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update_response do
      primary? true
      accept [:response_status, :comments]
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
    destroy :remove do
      primary? true
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

  identities do
    identity :unique_event_party, [:event_id, :party_id]
  end

end
