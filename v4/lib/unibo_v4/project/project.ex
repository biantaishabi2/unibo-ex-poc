# Workflow: project_lifecycle_flow — 项目正常生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   start --> [*]
#   complete --> [*]
# ```
# Workflow: project_archive_flow — 项目归档与取消归档流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   archive --> [*]
#   unarchive --> [*]
# ```
# Workflow: project_copy_destroy_flow — 项目复制与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   copy --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Project.Project do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Project.Project.Notifier]

  postgres do
    table "project_projects"
    repo UniboV4.Repo
  end

  graphql do
    type :project_project

    queries do
      get :get_project_project, :read
      list :list_project_projects, :read
    end

    mutations do
      create :create_create_project_project, :create
      create :create_copy_project_project, :copy
      update :update_project_project, :update
      update :start_project_project, :start
      update :complete_project_project, :complete
      update :archive_project_project, :archive
      update :unarchive_project_project, :unarchive
      destroy :delete_project_project, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :project_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :stage_id, :string do
      allow_nil? false
      public? true
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    attribute :privacy_visibility, :atom do
      constraints one_of: [:followers, :employees, :portal]
      default :portal
      public? true
    end
    attribute :last_update_status, :atom do
      constraints one_of: [:on_track, :at_risk, :off_track, :on_hold, :to_define, :done]
      default :to_define
      public? true
    end
    attribute :analytic_account_id, :string, public?: true
    attribute :partner_id, :string, public?: true
    attribute :company_id, :string do
      allow_nil? false
      public? true
    end
    attribute :allow_task_dependencies, :boolean do
      default false
      public? true
    end
    attribute :allow_milestones, :boolean do
      default false
      public? true
    end
    attribute :allow_timesheets, :boolean do
      default false
      public? true
    end
    attribute :label_tasks, :string do
      default "Tasks"
      public? true
    end
    attribute :resource_calendar_id, :string, public?: true
    attribute :start_date, :date, public?: true
    attribute :end_date, :date, public?: true
    attribute :color, :integer do
      default 0
      public? true
    end
    attribute :budget, :decimal, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :tasks, UniboV4.Project.Task do
      public? true
    end
    has_many :milestones, UniboV4.Project.Milestone do
      public? true
    end
    belongs_to :manager, UniboV4.Project.User do
      public? true
    end
    many_to_many :type_ids, UniboV4.Project.TaskStage do
      public? true
      through UniboV4.Project.ProjectTaskStageLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:project_code, :name, :start_date, :end_date, :budget, :description, :privacy_visibility, :allow_task_dependencies, :allow_milestones, :allow_timesheets, :label_tasks, :partner_id, :company_id, :resource_calendar_id]
      validate present(:project_code)
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 company_consistency
      # TODO: 不支持的 change effect auto_assign
      # TODO: 不支持的 change effect set_default
      change relate_actor(:manager)
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
      accept [:name, :start_date, :end_date, :budget, :description, :privacy_visibility, :active, :last_update_status, :allow_task_dependencies, :allow_milestones, :allow_timesheets, :label_tasks, :partner_id, :resource_calendar_id, :color]
      # skipped: validate company_consistency : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect unsubscribe_portal_users
      # TODO: 不支持的 change effect subscribe_partner
      # TODO: 不支持的 change effect sync_stage_to_company
      # TODO: 不支持的 change effect create_record
      # TODO: 不支持的 change effect cascade_update
      # TODO: 不支持的 change effect set_default
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
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :last_update_status)
        if current in [:to_define, :on_track, :at_risk, :off_track, :on_hold] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :last_update_status, message: "must be one of %{values}", vars: %{values: [:to_define, :on_track, :at_risk, :off_track, :on_hold]}))
        end
      end
      # message: "只有非完成状态可以启动"
      # skipped: validate company_consistency : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect unsubscribe_portal_users
      # TODO: 不支持的 change effect subscribe_partner
      # TODO: 不支持的 change effect sync_stage_to_company
      # TODO: 不支持的 change effect create_record
      # TODO: 不支持的 change effect cascade_update
      # TODO: 不支持的 change effect set_default
      change set_attribute(:last_update_status, :on_track)
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
      # skipped: validate company_consistency : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect unsubscribe_portal_users
      # TODO: 不支持的 change effect subscribe_partner
      # TODO: 不支持的 change effect sync_stage_to_company
      # TODO: 不支持的 change effect create_record
      # TODO: 不支持的 change effect cascade_update
      # TODO: 不支持的 change effect set_default
      change set_attribute(:last_update_status, :done)
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
    update :archive do
      accept []
      # skipped: validate company_consistency : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect cascade_update
      # TODO: 不支持的 change effect unsubscribe_portal_users
      # TODO: 不支持的 change effect subscribe_partner
      # TODO: 不支持的 change effect sync_stage_to_company
      # TODO: 不支持的 change effect create_record
      # TODO: 不支持的 change effect cascade_update
      # TODO: 不支持的 change effect set_default
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
    update :unarchive do
      accept []
      # skipped: validate company_consistency : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect cascade_update
      # TODO: 不支持的 change effect unsubscribe_portal_users
      # TODO: 不支持的 change effect subscribe_partner
      # TODO: 不支持的 change effect sync_stage_to_company
      # TODO: 不支持的 change effect create_record
      # TODO: 不支持的 change effect cascade_update
      # TODO: 不支持的 change effect set_default
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
      validate present(:project_code)
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 company_consistency
      # TODO: 不支持的 change effect auto_assign
      # TODO: 不支持的 change effect deep_copy
      # TODO: 不支持的 change effect set_default
      change relate_actor(:manager)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    destroy :destroy do
      # TODO: 不支持的 change effect conditional_cascade_delete
      # TODO: 不支持的 change effect cascade_delete
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

  identities do
    identity :unique_project_code, [:project_code]
  end

end
