# Workflow: attendance_write_flow — Attendance 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   check_out --> [*]
# ```
defmodule UniboV4.HR.Attendance do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "hr_attendances"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :check_in, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :check_out, :utc_datetime, public?: true
    attribute :worked_hours, :decimal, public?: true
    attribute :overtime_hours, :decimal, public?: true
    attribute :attendance_date, :date do
      allow_nil? false
      public? true
    end
    attribute :check_in_mode, :atom do
      constraints one_of: [:kiosk, :systray, :manual]
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:check_in, :attendance_date, :check_in_mode]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :check_out do
      accept [:check_out]
      # skipped: validate compare :check_out (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect compute
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
