# Workflow: approval_request_approve_flow — 审批请求正常通过流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   submit --> [*]
#   approve --> [*]
# ```
# Workflow: approval_request_refuse_resubmit_flow — 审批请求拒绝后重新提交流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   submit --> [*]
#   refuse --> [*]
#   draft --> [*]
#   submit --> [*]
# ```
# Workflow: approval_request_cancel_flow — 审批请求取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   submit --> [*]
#   cancel --> [*]
#   draft --> [*]
# ```
defmodule UniboExPoc.Approvals.ApprovalRequest do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Approvals.ApprovalRequest.Notifier]

  resource do
    description "审批请求单，关联审批类型并管理审批生命周期"
  end

  postgres do
    table "approvals_approval_requests"
    repo UniboExPoc.Repo
  end

  graphql do
    type :approvals_approval_request

    queries do
      get :get_approvals_approval_request, :read
      list :list_approvals_approval_requests, :read
    end

    mutations do
      create :create_approvals_approval_request, :create
      update :submit_approvals_approval_request, :submit
      update :approve_approvals_approval_request, :approve
      update :refuse_approvals_approval_request, :refuse
      update :cancel_approvals_approval_request, :cancel
      update :draft_approvals_approval_request, :draft
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "请求标题/编号"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:new, :pending, :approved, :refused, :cancel]
      default :new
      public? true
      description "请求状态"
    end
    attribute :request_date, :date do
      public? true
      description "提交日期（submit 时自动填充）"
    end
    attribute :date_confirmed, :utc_datetime do
      public? true
      description "最终审批/拒绝时间戳"
    end
    attribute :metadata, :string do
      public? true
      description "动态字段（金额、日期、地点、数量、参考编号等）"
    end
    attribute :reason, :string do
      public? true
      description "申请说明"
    end
    attribute :attachment_ids, {:array, :string} do
      public? true
      description "关联附件 ID 列表"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :approved_count, :integer, {UniboExPoc.Approvals.Calculations.ApprovalRequest.ApprovedCount, []}
    calculate :all_required_approved, :boolean, expr(all("status" == "approved"))
  end

  relationships do
    belongs_to :category, UniboExPoc.Approvals.ApprovalCategory do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :requester, UniboExPoc.Approvals.Party do
      public? true
      allow_nil? false
      source_attribute :requester_party_id
    end
    belongs_to :company, UniboExPoc.Approvals.Party do
      public? true
      allow_nil? false
      source_attribute :company_party_id
    end
    has_many :approvers, UniboExPoc.Approvals.Approver do
      public? true
      destination_attribute :request_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :reason, :metadata, :attachment_ids]
      argument :category_id, :integer, allow_nil?: false
      argument :company_id, :integer, allow_nil?: false
      change manage_relationship(:category_id, :category, type: :append, on_lookup: :relate)
      argument :requester_id, :uuid, allow_nil?: false
      change manage_relationship(:requester_id, :requester, type: :append, on_lookup: :relate)
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      argument :approvers, {:array, :map}, default: []
      change manage_relationship(:approvers, :approvers, type: :create)
      validate present(:name)
      change relate_actor(:requester)
      change set_attribute(:id, expr(id))
    end
    update :submit do
      description "提交审批"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :new do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :new}))
        end
      end
      # message: "只有草稿状态可以提交"
      change set_attribute(:status, :pending)
      change UniboExPoc.Approvals.Changes.ApprovalRequest.ComputeRequestDate
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :approve do
      description "审批通过（系统根据审批人状态自动触发）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待审批状态可以通过"
      change set_attribute(:status, :approved)
      change UniboExPoc.Approvals.Changes.ApprovalRequest.ComputeDateConfirmed
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :refuse do
      description "审批拒绝（系统根据审批人状态自动触发）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待审批状态可以拒绝"
      change set_attribute(:status, :refused)
      change UniboExPoc.Approvals.Changes.ApprovalRequest.ComputeDateConfirmed
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "申请人取消请求"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待审批状态可以取消"
      change set_attribute(:status, :cancel)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :draft do
      description "重置为草稿（从 refused/cancel 状态回退）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:refused, :cancel] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:refused, :cancel]}))
        end
      end
      # message: "只有拒绝或取消状态可以重置为草稿"
      change set_attribute(:status, :new)
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
