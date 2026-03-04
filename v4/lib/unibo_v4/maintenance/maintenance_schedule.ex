# Workflow: maintenance_schedule_maintain_flow — 预防性维护计划维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Maintenance.MaintenanceSchedule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "maintenance_schedules"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :schedule_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :frequency, :atom do
      allow_nil? false
      constraints one_of: [:daily, :weekly, :monthly, :quarterly, :yearly]
      public? true
    end
    attribute :next_due_date, :date do
      allow_nil? false
      public? true
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :equipment, UniboV4.Maintenance.Equipment do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:schedule_code, :name, :frequency, :next_due_date, :description]
      argument :equipment_id, :uuid, allow_nil?: false
      change manage_relationship(:equipment_id, :equipment, type: :append, on_lookup: :relate)
      validate present(:schedule_code)
      validate present(:name)
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
      accept [:name, :frequency, :next_due_date, :is_active, :description]
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

  identities do
    identity :unique_schedule_code, [:schedule_code]
  end

end
