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
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

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
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :employee_locations, UniboExPoc.HR.EmployeeLocation do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :location_type]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :location_type, :is_active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
