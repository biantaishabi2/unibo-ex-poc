# Workflow: recruitment_pipeline_flow — 招聘推进流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   advance --> [*]
#   hire --> [*]
#   archive --> [*]
# ```
# Workflow: application_reopen_flow — 候选人回流复审流程
# ```mermaid
# stateDiagram-v2
#   [*] --> reject
#   reject --> [*]
#   reset --> [*]
#   advance --> [*]
# ```
defmodule UniboExPoc.HR.JobApplication do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.HR.JobApplication.Notifier]

  resource do
    description "求职申请"
  end

  postgres do
    table "hr_job_applications"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_job_application

    queries do
      get :get_hr_job_application, :read
      list :list_hr_job_applications, :read
    end

    mutations do
      create :create_hr_job_application, :create
      update :advance_hr_job_application, :advance
      update :reject_hr_job_application, :reject
      update :hire_hr_job_application, :hire
      update :reset_hr_job_application, :reset
      update :archive_hr_job_application, :archive
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :applicant_name, :string do
      allow_nil? false
      public? true
    end
    attribute :email, :string do
      public? true
      description "去重用（标准化后比对）"
    end
    attribute :phone, :string, public?: true
    attribute :status, :atom do
      constraints one_of: [:received, :screening, :interview, :offer, :hired, :rejected, :archived]
      default :received
      public? true
    end
    attribute :kanban_state, :atom do
      constraints one_of: [:normal, :done, :blocked]
      default :normal
      public? true
      description "Kanban 状态，阶段切换时重置为 normal"
    end
    attribute :priority, :atom do
      constraints one_of: [:normal, :good, :very_good, :excellent]
      default :normal
      public? true
      description "候选人评分"
    end
    attribute :resume_summary, :string, public?: true
    attribute :notes, :string, public?: true
    attribute :applied_date, :date do
      allow_nil? false
      public? true
    end
    attribute :date_closed, :date do
      public? true
      description "录用/关闭日期（进入 hired 时自动设置）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :requisition, UniboExPoc.HR.JobRequisition do
      public? true
      allow_nil? false
    end
    many_to_many :interviewers, UniboExPoc.HR.Employee do
      public? true
      through UniboExPoc.HR.JobApplicationInterviewerLink
    end
    has_many :applicant_skills, UniboExPoc.HR.ApplicantSkill do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:applicant_name, :email, :phone, :resume_summary, :notes, :applied_date, :priority]
      argument :requisition_id, :uuid, allow_nil?: false
      change manage_relationship(:requisition_id, :requisition, type: :append, on_lookup: :relate)
      validate present(:applicant_name)
      # validation: custom_check
      change set_attribute(:id, expr(id))
    end
    update :advance do
      description "推进到下一阶段（阶段切换时 kanban_state 重置为 normal）"
      primary? true
      accept [:status]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:received, :screening, :interview] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:received, :screening, :interview]}))
        end
      end
      # message: "只有在招聘推进阶段内才允许推进"
      change set_attribute(:kanban_state, :normal)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reject do
      description "拒绝申请（触发 wizard 捕获拒绝原因）"
      accept [:notes]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:received, :screening, :interview, :offer] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:received, :screening, :interview, :offer]}))
        end
      end
      # message: "已录用或已拒绝的申请不能再拒绝"
      change set_attribute(:status, :rejected)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :hire do
      description "录用，自动创建 Employee 记录（填充 name、email、phone、department、job）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :offer do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :offer}))
        end
      end
      # message: "只有 offer 阶段可以录用"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :hired)
      change set_attribute(:date_closed, &Date.utc_today/0)
      change UniboExPoc.HR.Changes.JobApplication.HireCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reset do
      description "从拒绝重置到初始阶段"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :rejected do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :rejected}))
        end
      end
      # message: "只有已拒绝的可以重置"
      change set_attribute(:status, :received)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "归档"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:hired, :rejected] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:hired, :rejected]}))
        end
      end
      # message: "仅录用或拒绝后的申请允许归档"
      change set_attribute(:status, :archived)
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
