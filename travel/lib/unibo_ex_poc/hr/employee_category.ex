# Workflow: employee_category_write_flow — EmployeeCategory 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.EmployeeCategory do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "员工标签"
  end

  postgres do
    table "hr_employee_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_employee_category

    queries do
      get :get_hr_employee_category, :read
      list :list_hr_employee_categorys, :read
    end

    mutations do
      create :create_hr_employee_category, :create
      update :update_hr_employee_category, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :color, :integer do
      default 0
      public? true
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
    many_to_many :employees, UniboExPoc.HR.Employee do
      public? true
      through UniboExPoc.HR.EmployeeCategoryLink
      source_attribute_on_join_resource :category_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Employee Category via Create. doc_url: graphql://contract/hr/create_hr_employee_category"
      primary? true
      accept [:name, :color]
      validate present(:name)
    end
    update :update do
      description "Update Employee Category via Update. doc_url: graphql://contract/hr/update_hr_employee_category"
      primary? true
      accept [:name, :color]
      require_atomic? false
    end
  end

end
