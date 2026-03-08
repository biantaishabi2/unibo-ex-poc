# Workflow: employee_location_write_flow — EmployeeLocation 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.EmployeeLocation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "员工每日工作地点（异常/临时覆盖）"
  end

  postgres do
    table "hr_employee_locations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_employee_location

    queries do
      get :get_hr_employee_location, :read
      list :list_hr_employee_locations, :read
    end

    mutations do
      create :create_hr_employee_location, :create
      update :update_hr_employee_location, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :date, :date do
      allow_nil? false
      public? true
      description "工作日期"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :work_location, UniboExPoc.HR.WorkLocation do
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
      # validation: custom_check
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
