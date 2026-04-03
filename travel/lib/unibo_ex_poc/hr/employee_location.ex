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
    extensions: [AshGraphql.Resource]

  resource do
    description "员工每日工作地点（异常/临时覆盖）"
  end

  postgres do
    table "hr_employee_locations"
    repo UniboExPoc.Repo
    identity_index_names unique_employee_date: "idx_hr_employee_locations_unique_employee_date"
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
    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :updated_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      update_default &DateTime.utc_now/0
      public? true
    end
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
      description "Create Employee Location via Create. doc_url: graphql://contract/hr/create_hr_employee_location"
      primary? true
      accept [:date]
      argument :employee_id, :uuid, allow_nil?: false
      argument :work_location_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change manage_relationship(:work_location_id, :work_location, type: :append, on_lookup: :relate)
      validate present(:date)
      # validation: custom_check
    end
    update :update do
      description "Update Employee Location via Update. doc_url: graphql://contract/hr/update_hr_employee_location"
      primary? true
      accept []
      argument :work_location_id, :uuid
      require_atomic? false
    end
  end

  identities do
    identity :unique_employee_date, [:employee_id, :date]
  end

end
