# Workflow: requisition_filled_flow — 招聘需求发布并完成流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   open --> [*]
#   close --> [*]
# ```
# Workflow: requisition_cancel_flow — 招聘需求发布后取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   open --> [*]
#   cancel --> [*]
# ```
defmodule UniboExPoc.HR.JobRequisition do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.HR.JobRequisition.Notifier]

  resource do
    description "招聘需求"
  end

  postgres do
    table "hr_job_requisitions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_job_requisition

    queries do
      get :get_hr_job_requisition, :read
      list :list_hr_job_requisitions, :read
    end

    mutations do
      create :create_hr_job_requisition, :create
      update :open_hr_job_requisition, :open
      update :close_hr_job_requisition, :close
      update :cancel_hr_job_requisition, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :requisition_number, :string do
      allow_nil? false
      public? true
      description "唯一编号"
    end
    attribute :job_title, :string do
      allow_nil? false
      public? true
    end
    attribute :headcount, :integer do
      allow_nil? false
      public? true
      description "招聘人数"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :open, :in_progress, :filled, :cancelled]
      default :draft
      public? true
    end
    attribute :priority, :atom do
      constraints one_of: [:low, :medium, :high, :urgent]
      default :medium
      public? true
    end
    attribute :description, :string do
      public? true
      description "职位描述"
    end
    attribute :requirements, :string do
      public? true
      description "岗位要求"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :department, UniboExPoc.HR.Department do
      public? true
    end
    has_many :applications, UniboExPoc.HR.JobApplication do
      public? true
      source_attribute :department_id
      destination_attribute :requisition_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:requisition_number, :job_title, :headcount, :priority, :description, :requirements]
      argument :department_id, :uuid
      validate present(:requisition_number)
      change set_attribute(:id, expr(id))
    end
    update :open do
      description "发布招聘"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发布"
      change set_attribute(:status, :open)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :close do
      description "关闭招聘（hired_count >= headcount 时为 filled，也可强制关闭）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:open, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:open, :in_progress]}))
        end
      end
      # message: "只有已发布或进行中状态可以关闭"
      change set_attribute(:status, :filled)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消招聘（不级联取消已有的 JobApplication）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :open, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :open, :in_progress]}))
        end
      end
      # message: "已关闭或已取消的不能再取消"
      change set_attribute(:status, :cancelled)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:headcount, greater_than: 0)
  end

  identities do
    identity :unique_requisition_number, [:requisition_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
