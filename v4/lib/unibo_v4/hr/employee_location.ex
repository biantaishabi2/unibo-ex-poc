# Workflow: employee_location_write_flow — EmployeeLocation 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.EmployeeLocation do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "hr_employee_locations"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :date, :date do
      allow_nil? false
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
    belongs_to :work_location, UniboV4.HR.WorkLocation do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:date]
      argument :employee_id, :uuid, allow_nil?: false
      argument :work_location_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change manage_relationship(:work_location_id, :work_location, type: :append, on_lookup: :relate)
      validate present(:date)
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
    update :update do
      primary? true
      accept []
      argument :work_location_id, :uuid
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
    identity :unique_employee_date, [:employee_id, :date]
  end

end
