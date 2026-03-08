# Workflow: task_lifecycle_flow — 任务正常生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   assign --> [*]
#   start --> [*]
#   complete --> [*]
# ```
# Workflow: task_cancel_reopen_flow — 任务取消并重新打开流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   start --> [*]
#   cancel --> [*]
#   reopen --> [*]
# ```
# Workflow: task_edit_copy_flow — 任务编辑与复制流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   copy --> [*]
# ```
defmodule UniboExPoc.Project.Task do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Project.Task.Notifier]

  resource do
    description "任务"
  end

  postgres do
    table "project_tasks"
    repo UniboExPoc.Repo
  end

  graphql do
    type :project_task

    queries do
      get :get_project_task, :read
      list :list_project_tasks, :read
    end

    mutations do
      create :create_create_project_task, :create
      create :create_copy_project_task, :copy
      update :update_project_task, :update
      update :start_project_task, :start
      update :complete_project_task, :complete
      update :cancel_project_task, :cancel
      update :reopen_project_task, :reopen
      update :assign_project_task, :assign
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "任务名称"
    end
    attribute :state, :atom do
      constraints one_of: [:"01_in_progress", :"02_changes_requested", :"03_approved", :"04_waiting_normal", :"1_done", :"1_canceled"]
      default :"01_in_progress"
      public? true
      description "任务状态（由状态机管理）"
    end
    attribute :priority, :atom do
      constraints one_of: [:"0", :"1"]
      default :"0"
      public? true
      description "优先级 0=Normal / 1=High"
    end
    attribute :kanban_state, :atom do
      constraints one_of: [:normal, :done, :blocked]
      default :normal
      public? true
      description "看板状态"
    end
    attribute :user_ids, :string do
      public? true
      description "负责人（多人）"
    end
    attribute :date_assign, :utc_datetime do
      public? true
      description "首次分配负责人时间（自动记录）"
    end
    attribute :date_deadline, :date do
      public? true
      description "截止日期"
    end
    attribute :date_end, :utc_datetime do
      public? true
      description "任务关闭时间（自动记录）"
    end
    attribute :date_last_stage_update, :utc_datetime do
      public? true
      description "最后阶段变更时间（自动记录）"
    end
    attribute :allocated_hours, :decimal do
      default 0
      public? true
      description "预估工时"
    end
    attribute :recurring_task, :boolean do
      default false
      public? true
      description "是否周期任务"
    end
    attribute :tag_ids, :string do
      public? true
      description "标签"
    end
    attribute :description, :string do
      public? true
      description "任务描述"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :project, UniboExPoc.Project.Project do
      public? true
    end
    belongs_to :parent, UniboExPoc.Project.Task do
      public? true
    end
    has_many :child_ids, UniboExPoc.Project.Task do
      public? true
      source_attribute :parent_id
      destination_attribute :parent_id
    end
    many_to_many :depend_on_ids, UniboExPoc.Project.Task do
      public? true
      through UniboExPoc.Project.TaskDependency
      source_attribute_on_join_resource :depends_on_id
      destination_attribute_on_join_resource :depends_on_id
    end
    many_to_many :dependent_ids, UniboExPoc.Project.Task do
      public? true
      through UniboExPoc.Project.TaskDependency
      source_attribute_on_join_resource :depends_on_id
      destination_attribute_on_join_resource :depends_on_id
    end
    has_many :assignments, UniboExPoc.Project.TaskAssignment do
      public? true
    end
    has_many :dependencies, UniboExPoc.Project.TaskDependency do
      public? true
    end
    has_many :timesheet_ids, UniboExPoc.Project.TimesheetEntry do
      public? true
    end
    belongs_to :stage, UniboExPoc.Project.TaskStage do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboExPoc.Project.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :milestone, UniboExPoc.Project.Milestone do
      public? true
    end
    belongs_to :recurrence, UniboExPoc.Project.TaskRecurrence do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :priority, :date_deadline, :allocated_hours, :description, :parent_id, :milestone_id, :tag_ids, :recurring_task, :kanban_state]
      argument :project_id, :uuid
      argument :stage_id, :uuid, allow_nil?: false
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
      validate present(:name)
      validate {UniboExPoc.Project.Validations.Task.NoCircularDependency, []}
      # message: "两个任务之间禁止循环依赖（A 阻塞 B 且 B 阻塞 A）"
      # validation: custom_check — 周期性任务不能作为子任务（parent_id 必须为空）
      # validation: custom_check — 私人任务（无 project_id）不能有 parent_id
      change UniboExPoc.Project.Changes.Task.CreateCall13
      change UniboExPoc.Project.Changes.Task.CreateCall14
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
      accept [:name, :state, :priority, :date_deadline, :allocated_hours, :description, :stage_id, :user_ids, :parent_id, :milestone_id, :tag_ids, :kanban_state, :project_id]
      argument :depend_on_ids, :uuid
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      change UniboExPoc.Project.Changes.Task.UpdateCall8
      change UniboExPoc.Project.Changes.Task.UpdateCall12
      change UniboExPoc.Project.Changes.Task.UpdateCall13
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
    update :start do
      description "开始任务"
      accept []
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      change UniboExPoc.Project.Changes.Task.StartCall8
      change UniboExPoc.Project.Changes.Task.StartCall12
      change UniboExPoc.Project.Changes.Task.StartCall13
      change set_attribute(:state, :"01_in_progress")
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
    update :complete do
      description "完成任务"
      accept []
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      change UniboExPoc.Project.Changes.Task.CompleteCall7
      change UniboExPoc.Project.Changes.Task.CompleteCall8
      change UniboExPoc.Project.Changes.Task.CompleteCall12
      change UniboExPoc.Project.Changes.Task.CompleteCall13
      change set_attribute(:state, :"1_done")
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
    update :cancel do
      description "取消任务"
      accept []
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      change UniboExPoc.Project.Changes.Task.CancelCall7
      change UniboExPoc.Project.Changes.Task.CancelCall8
      change UniboExPoc.Project.Changes.Task.CancelCall12
      change UniboExPoc.Project.Changes.Task.CancelCall13
      change set_attribute(:state, :"1_canceled")
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
    update :reopen do
      description "重新打开任务"
      accept [:stage_id]
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      change UniboExPoc.Project.Changes.Task.ReopenCall8
      change UniboExPoc.Project.Changes.Task.ReopenCall12
      change UniboExPoc.Project.Changes.Task.ReopenCall13
      change set_attribute(:state, :"01_in_progress")
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
    create :copy do
      description "复制任务"
      accept []
      argument :stage_id, :uuid, allow_nil?: false
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
      validate present(:name)
      validate {UniboExPoc.Project.Validations.Task.NoCircularDependency, []}
      # message: "两个任务之间禁止循环依赖（A 阻塞 B 且 B 阻塞 A）"
      # validation: custom_check — 周期性任务不能作为子任务（parent_id 必须为空）
      # validation: custom_check — 私人任务（无 project_id）不能有 parent_id
      change UniboExPoc.Project.Changes.Task.CopyCall11
      change UniboExPoc.Project.Changes.Task.CopyCall13
      change UniboExPoc.Project.Changes.Task.CopyCall14
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :assign do
      description "分配负责人"
      accept [:user_ids]
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      change UniboExPoc.Project.Changes.Task.AssignCall8
      change UniboExPoc.Project.Changes.Task.AssignCall12
      change UniboExPoc.Project.Changes.Task.AssignCall13
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
