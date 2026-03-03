# Workflow: task_assignment_write_flow — 任务分配写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Project.TaskAssignment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "project_task_assignments"
    repo UniboV4.Repo
  end

  graphql do
    type :project_task_assignment

    queries do
      get :get_project_task_assignment, :read
      list :list_project_task_assignments, :read
    end

    mutations do
      create :create_project_task_assignment, :create
      destroy :delete_project_task_assignment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string, public?: true
    attribute :from_date, :date do
      allow_nil? false
      public? true
    end
    attribute :thru_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :task, UniboV4.Project.Task do
      public? true
      allow_nil? false
    end
    belongs_to :assignee, UniboV4.Project.User do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept [:role, :from_date, :thru_date]
      argument :task_id, :uuid, allow_nil?: false
      argument :assignee_id, :uuid, allow_nil?: false
      change manage_relationship(:task_id, :task, type: :append, on_lookup: :relate)
      change manage_relationship(:assignee_id, :assignee, type: :append, on_lookup: :relate)
      validate present(:from_date)
      # message: "分配开始日期不能为空"
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
