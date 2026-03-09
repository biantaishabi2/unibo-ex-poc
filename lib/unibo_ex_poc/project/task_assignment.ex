# Workflow: task_assignment_write_flow — 任务分配写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Project.TaskAssignment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "任务分配（逻辑模型，Odoo 用 task.user_ids M2M 实现）"
  end

  postgres do
    table "project_task_assignments"
    repo UniboExPoc.Repo
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
    attribute :role, :string do
      public? true
      description "分配角色"
    end
    attribute :from_date, :date do
      allow_nil? false
      public? true
    end
    attribute :thru_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :task, UniboExPoc.Project.Task do
      public? true
      allow_nil? false
    end
    belongs_to :assignee, UniboExPoc.Project.Party do
      public? true
      allow_nil? false
      source_attribute :assignee_party_id
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
