# Workflow: work_location_write_flow — WorkLocation 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.WorkLocation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "工作地点定义（如\"办公室\"、\"居家\"、\"其他\"）"
  end

  postgres do
    table "hr_work_locations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_work_location

    queries do
      get :get_hr_work_location, :read
      list :list_hr_work_locations, :read
    end

    mutations do
      create :create_hr_work_location, :create
      update :update_hr_work_location, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "地点名称"
    end
    attribute :location_type, :atom do
      allow_nil? false
      constraints one_of: [:home, :office, :other]
      public? true
      description "地点类型"
    end
    attribute :is_active, :boolean do
      default true
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
    has_many :employee_locations, UniboExPoc.HR.EmployeeLocation do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Work Location via Create. doc_url: graphql://contract/hr/create_hr_work_location"
      primary? true
      accept [:name, :location_type]
      validate present(:name)
    end
    update :update do
      description "Update Work Location via Update. doc_url: graphql://contract/hr/update_hr_work_location"
      primary? true
      accept [:name, :location_type, :is_active]
      require_atomic? false
    end
  end

end
