# Workflow: task_dependency_write_flow — 任务依赖写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Project.TaskDependency do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "project_task_dependencies"
    repo UniboV4.Repo
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
  end

  relationships do
    belongs_to :task, UniboV4.Project.Task do
      public? true
      allow_nil? false
    end
    belongs_to :depends_on, UniboV4.Project.Task do
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
      # TODO: 不支持的 action 内校验规则 no_circular_dependency
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

end
