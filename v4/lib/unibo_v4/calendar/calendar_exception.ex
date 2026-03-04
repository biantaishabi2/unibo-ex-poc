# Workflow: calendar_exception_manage_flow — 日历例外管理
# ```mermaid
# stateDiagram-v2
#   [*] --> add
#   add --> remove
#   remove --> [*]
# ```
defmodule UniboV4.Calendar.CalendarException do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Calendar,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "calendar_exceptions"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :exception_date, :date do
      allow_nil? false
      public? true
    end
    attribute :exception_type, :atom do
      allow_nil? false
      constraints one_of: [:holiday, :special_working, :half_day, :overtime]
      public? true
    end
    attribute :description, :string, public?: true
    attribute :exception_capacity, :float, public?: true
    attribute :start_time, :string, public?: true
    attribute :end_time, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :work_schedule, UniboV4.Calendar.WorkSchedule do
      public? true
      allow_nil? false
    end
    has_many :translations, UniboV4.Calendar.CalendarExceptionTranslation, public?: true
  end

  actions do
    defaults [:read]
    create :add do
      primary? true
      accept [:exception_date, :exception_type, :description, :exception_capacity, :start_time, :end_time]
      argument :work_schedule_id, :uuid, allow_nil?: false
      change manage_relationship(:work_schedule_id, :work_schedule, type: :append, on_lookup: :relate)
      validate present(:work_schedule_id)
      validate present(:exception_date)
      validate present(:exception_type)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
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
    identity :unique_schedule_date, [:work_schedule_id, :exception_date]
  end

end
