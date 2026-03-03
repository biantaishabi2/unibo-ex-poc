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
defmodule UniboV4.Project.Task do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Project.Task.Notifier]

  postgres do
    table "project_tasks"
    repo UniboV4.Repo
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
    end
    attribute :stage_id, :string do
      allow_nil? false
      public? true
    end
    attribute :state, :atom do
      constraints one_of: [:"01_in_progress", :"02_changes_requested", :"03_approved", :"04_waiting_normal", :"1_done", :"1_canceled"]
      default :"01_in_progress"
      public? true
    end
    attribute :priority, :atom do
      constraints one_of: [:"0", :"1"]
      default :"0"
      public? true
    end
    attribute :kanban_state, :atom do
      constraints one_of: [:normal, :done, :blocked]
      default :normal
      public? true
    end
    attribute :user_ids, :string, public?: true
    attribute :partner_id, :string, public?: true
    attribute :milestone_id, :string, public?: true
    attribute :date_assign, :utc_datetime, public?: true
    attribute :date_deadline, :date, public?: true
    attribute :date_end, :utc_datetime, public?: true
    attribute :date_last_stage_update, :utc_datetime, public?: true
    attribute :allocated_hours, :decimal do
      default 0
      public? true
    end
    attribute :recurring_task, :boolean do
      default false
      public? true
    end
    attribute :recurrence_id, :string, public?: true
    attribute :tag_ids, :string, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :project, UniboV4.Project.Project do
      public? true
    end
    belongs_to :parent, UniboV4.Project.Task do
      public? true
    end
    has_many :child_ids, UniboV4.Project.Task do
      public? true
      destination_attribute :parent_id
    end
    many_to_many :depend_on_ids, UniboV4.Project.Task do
      public? true
      through UniboV4.Project.TaskDependency
    end
    many_to_many :dependent_ids, UniboV4.Project.Task do
      public? true
      through UniboV4.Project.TaskDependency
    end
    has_many :assignments, UniboV4.Project.TaskAssignment do
      public? true
    end
    has_many :dependencies, UniboV4.Project.TaskDependency do
      public? true
    end
    has_many :timesheet_ids, UniboV4.Project.TimesheetEntry do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :priority, :date_deadline, :allocated_hours, :description, :milestone_id, :tag_ids, :recurring_task, :kanban_state]
      argument :project_id, :uuid
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 no_circular_dependency
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 change effect parse_display_name
      # TODO: 不支持的 change effect portal_access_check
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
      accept [:name, :state, :priority, :date_deadline, :allocated_hours, :description, :stage_id, :user_ids, :milestone_id, :tag_ids, :kanban_state]
      argument :depend_on_ids, :uuid
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      # TODO: 不支持的 change effect send_rating_request
      # TODO: 不支持的 change effect sync_stage_to_project
      # TODO: 不支持的 change effect parse_display_name
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
      accept []
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      # TODO: 不支持的 change effect send_rating_request
      # TODO: 不支持的 change effect sync_stage_to_project
      # TODO: 不支持的 change effect parse_display_name
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
      accept []
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      # TODO: 不支持的 change effect create_next_recurrence
      # TODO: 不支持的 change effect send_rating_request
      # TODO: 不支持的 change effect sync_stage_to_project
      # TODO: 不支持的 change effect parse_display_name
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
      accept []
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      # TODO: 不支持的 change effect create_next_recurrence
      # TODO: 不支持的 change effect send_rating_request
      # TODO: 不支持的 change effect sync_stage_to_project
      # TODO: 不支持的 change effect parse_display_name
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
      accept [:stage_id]
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      # TODO: 不支持的 change effect send_rating_request
      # TODO: 不支持的 change effect sync_stage_to_project
      # TODO: 不支持的 change effect parse_display_name
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
      accept []
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 no_circular_dependency
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 change effect deep_copy
      # TODO: 不支持的 change effect parse_display_name
      # TODO: 不支持的 change effect portal_access_check
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
      accept [:user_ids]
      # skipped: validate no_circular_dependency :depend_on_ids (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:date_assign, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      change set_attribute(:date_end, &DateTime.utc_now/0)
      change set_attribute(:state, :"04_waiting_normal")
      # TODO: 不支持的 change effect send_rating_request
      # TODO: 不支持的 change effect sync_stage_to_project
      # TODO: 不支持的 change effect parse_display_name
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

end
