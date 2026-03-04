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
defmodule UniboV4.HR.JobApplication do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.HR.JobApplication.Notifier]

  postgres do
    table "hr_job_applications"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :applicant_name, :string do
      allow_nil? false
      public? true
    end
    attribute :email, :string, public?: true
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
    end
    attribute :priority, :atom do
      constraints one_of: [:normal, :good, :very_good, :excellent]
      default :normal
      public? true
    end
    attribute :resume_summary, :string, public?: true
    attribute :notes, :string, public?: true
    attribute :applied_date, :date do
      allow_nil? false
      public? true
    end
    attribute :date_closed, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :requisition, UniboV4.HR.JobRequisition do
      public? true
      allow_nil? false
    end
    many_to_many :interviewers, UniboV4.HR.Employee do
      public? true
      through UniboV4.HR.JobApplicationInterviewerLink
    end
    has_many :applicant_skills, UniboV4.HR.ApplicantSkill do
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
      # TODO: 不支持的 action 内校验规则 custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :advance do
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
    update :reject do
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
    update :hire do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :hired)
      change set_attribute(:date_closed, &Date.utc_today/0)
      # TODO: 不支持的 change effect custom
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
    update :reset do
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
