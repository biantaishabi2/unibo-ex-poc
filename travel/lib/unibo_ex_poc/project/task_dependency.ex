# Workflow: task_dependency_write_flow — 任务依赖写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Project.TaskDependency do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "任务依赖关系"
  end

  postgres do
    table "project_task_dependencies"
    repo UniboExPoc.Repo
  end

  graphql do
    type :project_task_dependency

    queries do
      get :get_project_task_dependency, :read
      list :list_project_task_dependencys, :read
    end

    mutations do
      create :create_project_task_dependency, :create
      destroy :delete_project_task_dependency, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :dependency_type, :atom do
      constraints one_of: [:finish_to_start, :start_to_start, :finish_to_finish]
      default :finish_to_start
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :task, UniboExPoc.Project.Task do
      public? true
      allow_nil? false
    end
    belongs_to :depends_on, UniboExPoc.Project.Task do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept [:dependency_type]
      argument :task_id, :uuid, allow_nil?: false
      argument :depends_on_id, :uuid, allow_nil?: false
      change manage_relationship(:task_id, :task, type: :append, on_lookup: :relate)
      change manage_relationship(:depends_on_id, :depends_on, type: :append, on_lookup: :relate)
      validate {UniboExPoc.Project.Validations.TaskDependency.NoCircularDependency, []}
      # message: "禁止循环依赖"
      change set_attribute(:id, expr(id))
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
