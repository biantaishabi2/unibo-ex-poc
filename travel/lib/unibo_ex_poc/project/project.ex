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
defmodule UniboExPoc.Project.Project do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Project.Project.Notifier]

  resource do
    description "项目"
  end

  postgres do
    table "project_projects"
    repo UniboExPoc.Repo
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
      description "项目编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "项目名称"
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
      description "归档标志"
    end
    attribute :privacy_visibility, :atom do
      constraints one_of: [:followers, :employees, :portal]
      default :portal
      public? true
      description "可见性设置"
    end
    attribute :last_update_status, :atom do
      constraints one_of: [:on_track, :at_risk, :off_track, :on_hold, :to_define, :done]
      default :to_define
      public? true
      description "项目状态更新"
    end
    attribute :allow_task_dependencies, :boolean do
      default false
      public? true
      description "启用任务依赖/阻塞"
    end
    attribute :allow_milestones, :boolean do
      default false
      public? true
      description "启用里程碑"
    end
    attribute :allow_timesheets, :boolean do
      default false
      public? true
      description "启用工时记录"
    end
    attribute :label_tasks, :string do
      default "Tasks"
      public? true
      description "任务标签文本，空字符串时自动重置为 Tasks"
    end
    attribute :start_date, :date do
      public? true
      description "项目开始日期"
    end
    attribute :end_date, :date do
      public? true
      description "项目截止日期"
    end
    attribute :color, :integer do
      default 0
      public? true
      description "看板颜色索引"
    end
    attribute :budget, :decimal do
      public? true
      description "项目预算"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :tasks, UniboExPoc.Project.Task do
      public? true
    end
    has_many :milestones, UniboExPoc.Project.Milestone do
      public? true
    end
    belongs_to :manager, UniboExPoc.Project.Party do
      public? true
      source_attribute :manager_party_id
    end
    many_to_many :type_ids, UniboExPoc.Project.TaskStage do
      public? true
      through UniboExPoc.Project.ProjectTaskStageLink
    end
    belongs_to :stage, UniboExPoc.Project.ProjectStage do
      public? true
      allow_nil? false
    end
    belongs_to :analytic_account, UniboExPoc.Project.AnalyticAccount do
      public? true
    end
    belongs_to :partner, UniboExPoc.Project.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :company, UniboExPoc.Project.Party do
      public? true
      allow_nil? false
      source_attribute :company_party_id
    end
    belongs_to :resource_calendar, UniboExPoc.Project.ResourceCalendar do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:project_code, :name, :start_date, :end_date, :budget, :description, :privacy_visibility, :allow_task_dependencies, :allow_milestones, :allow_timesheets, :label_tasks, :resource_calendar_id]
      argument :partner_id, :uuid
      argument :company_id, :uuid
      argument :stage_id, :uuid, allow_nil?: false
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
      argument :company_id, :uuid, allow_nil?: false
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:project_code)
      validate present(:name)
      validate {UniboExPoc.Project.Validations.Project.CompanyConsistency, []}
      # message: "项目各阶段、分析账户、合作伙伴的 company_id 必须与项目一致"
      change UniboExPoc.Project.Changes.Project.CreateCall1
      change set_attribute(:label_tasks, :Tasks)
      change relate_actor(:manager)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :start_date, :end_date, :budget, :description, :privacy_visibility, :active, :last_update_status, :allow_task_dependencies, :allow_milestones, :allow_timesheets, :label_tasks, :resource_calendar_id, :color]
      argument :partner_id, :uuid
      # skipped: validate company_consistency : (incompatible with bulk update atomic path)
      change UniboExPoc.Project.Changes.Project.UpdateCall4
      change UniboExPoc.Project.Changes.Project.UpdateCall5
      change UniboExPoc.Project.Changes.Project.UpdateCall6
      change UniboExPoc.Project.Changes.Project.UpdateCreateRelated7
      # cascade_update :state — Ash 暂无内置支持，需用 change fn 手动实现
      change set_attribute(:label_tasks, :Tasks)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :start do
      description "启动项目"
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
      change UniboExPoc.Project.Changes.Project.StartCall4
      change UniboExPoc.Project.Changes.Project.StartCall5
      change UniboExPoc.Project.Changes.Project.StartCall6
      change UniboExPoc.Project.Changes.Project.StartCreateRelated7
      # cascade_update :state — Ash 暂无内置支持，需用 change fn 手动实现
      change set_attribute(:label_tasks, :Tasks)
      change set_attribute(:last_update_status, :on_track)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :complete do
      description "完成项目"
      accept []
      # skipped: validate company_consistency : (incompatible with bulk update atomic path)
      change UniboExPoc.Project.Changes.Project.CompleteCall4
      change UniboExPoc.Project.Changes.Project.CompleteCall5
      change UniboExPoc.Project.Changes.Project.CompleteCall6
      change UniboExPoc.Project.Changes.Project.CompleteCreateRelated7
      # cascade_update :state — Ash 暂无内置支持，需用 change fn 手动实现
      change set_attribute(:label_tasks, :Tasks)
      change set_attribute(:last_update_status, :done)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "归档项目"
      accept []
      # skipped: validate company_consistency : (incompatible with bulk update atomic path)
      # cascade_update :active — Ash 暂无内置支持，需用 change fn 手动实现
      change UniboExPoc.Project.Changes.Project.ArchiveCall4
      change UniboExPoc.Project.Changes.Project.ArchiveCall5
      change UniboExPoc.Project.Changes.Project.ArchiveCall6
      change UniboExPoc.Project.Changes.Project.ArchiveCreateRelated7
      # cascade_update :state — Ash 暂无内置支持，需用 change fn 手动实现
      change set_attribute(:label_tasks, :Tasks)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unarchive do
      description "取消归档"
      accept []
      # skipped: validate company_consistency : (incompatible with bulk update atomic path)
      # cascade_update :active — Ash 暂无内置支持，需用 change fn 手动实现
      change UniboExPoc.Project.Changes.Project.UnarchiveCall4
      change UniboExPoc.Project.Changes.Project.UnarchiveCall5
      change UniboExPoc.Project.Changes.Project.UnarchiveCall6
      change UniboExPoc.Project.Changes.Project.UnarchiveCreateRelated7
      # cascade_update :state — Ash 暂无内置支持，需用 change fn 手动实现
      change set_attribute(:label_tasks, :Tasks)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    create :copy do
      description "复制项目"
      accept []
      argument :stage_id, :uuid, allow_nil?: false
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
      argument :company_id, :uuid, allow_nil?: false
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:project_code)
      validate present(:name)
      validate {UniboExPoc.Project.Validations.Project.CompanyConsistency, []}
      # message: "项目各阶段、分析账户、合作伙伴的 company_id 必须与项目一致"
      change UniboExPoc.Project.Changes.Project.CopyCall1
      change UniboExPoc.Project.Changes.Project.CopyCall10
      change set_attribute(:label_tasks, :Tasks)
      change relate_actor(:manager)
      change set_attribute(:id, expr(id))
    end
    destroy :destroy do
      description "删除项目"
      # cascade_destroy — 缺少 field，跳过
      # cascade_destroy — 缺少 field，跳过
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_project_code, [:project_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:tasks, :milestones]
  end

end
