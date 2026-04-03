defmodule UniboExPoc.Approvals.ApprovalRequest do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "审批请求单，关联审批类型并管理审批生命周期（提交/通过/拒绝/取消/重提交）"
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
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "请求标题/编号"
    end
    attribute :request_status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :submitted, :approved, :refused, :cancelled]
      default :draft
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
    attribute :reason, :string do
      public? true
      description "申请说明"
    end
    attribute :metadata, :map do
      public? true
      description "动态字段（金额、日期、地点、数量、参考编号等）"
    end
    attribute :attachment_ids, :string do
      public? true
      description "关联附件 ID 列表"
    end
    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :updated_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      update_default &DateTime.utc_now/0
      public? true
    end
  end

  relationships do
    belongs_to :category, UniboExPoc.Approvals.ApprovalCategory do
      public? true
      allow_nil? false
    end
    belongs_to :requester_party, UniboExPoc.Approvals.Party do
      public? true
      allow_nil? false
    end
    belongs_to :company_party, UniboExPoc.Approvals.Party do
      public? true
      allow_nil? false
    end
    has_many :approvers, UniboExPoc.Approvals.Approver do
      public? true
      destination_attribute :request_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Approval Request via Create. doc_url: graphql://contract/approvals/create_approvals_approval_request"
      primary? true
      accept [:name, :reason, :metadata, :attachment_ids, :category_id, :requester_party_id, :company_party_id]
      argument :category_id, :uuid, allow_nil?: false
      change manage_relationship(:category_id, :category, type: :append, on_lookup: :relate)
      argument :requester_party_id, :uuid, allow_nil?: false
      change manage_relationship(:requester_party_id, :requester_party, type: :append, on_lookup: :relate)
      argument :company_party_id, :uuid, allow_nil?: false
      change manage_relationship(:company_party_id, :company_party, type: :append, on_lookup: :relate)
    end
    update :submit do
      description "提交审批

提交审批. doc_url: graphql://contract/approvals/submit_approvals_approval_request"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :request_status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :request_status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以提交"
      change set_attribute(:request_status, :submitted)
      change set_attribute(:request_date, &Date.utc_today/0)
      change AshStateMachine.BuiltinChanges.transition_state(:submitted)
      require_atomic? false
    end
    update :approve do
      description "审批通过（系统根据审批人状态自动触发）

审批通过（系统根据审批人状态自动触发）. doc_url: graphql://contract/approvals/approve_approvals_approval_request"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :request_status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :request_status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有已提交状态可以审批/拒绝/取消"
      change set_attribute(:request_status, :approved)
      change set_attribute(:date_confirmed, &DateTime.utc_now/0)
      change AshStateMachine.BuiltinChanges.transition_state(:approved)
      require_atomic? false
    end
    update :refuse do
      description "审批拒绝（系统根据审批人状态自动触发）

审批拒绝（系统根据审批人状态自动触发）. doc_url: graphql://contract/approvals/refuse_approvals_approval_request"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :request_status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :request_status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有已提交状态可以审批/拒绝/取消"
      change set_attribute(:date_confirmed, &DateTime.utc_now/0)
      change set_attribute(:request_status, :refused)
      change AshStateMachine.BuiltinChanges.transition_state(:refused)
      require_atomic? false
    end
    update :cancel do
      description "申请人取消请求

申请人取消请求. doc_url: graphql://contract/approvals/cancel_approvals_approval_request"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :request_status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :request_status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有已提交状态可以审批/拒绝/取消"
      change set_attribute(:request_status, :cancelled)
      change AshStateMachine.BuiltinChanges.transition_state(:cancelled)
      require_atomic? false
    end
    update :draft do
      description "重置为草稿（从 refused/cancelled 状态回退，支持重提交）

重置为草稿（从 refused/cancelled 状态回退，支持重提交）. doc_url: graphql://contract/approvals/draft_approvals_approval_request"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :request_status)
        if current in [:refused, :cancelled] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :request_status, message: "must be one of %{values}", vars: %{values: [:refused, :cancelled]}))
        end
      end
      # message: "只有拒绝或取消状态可以重置为草稿"
      change set_attribute(:request_status, :draft)
      change AshStateMachine.BuiltinChanges.transition_state(:draft)
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:draft]
    default_initial_state :draft
    extra_states [:draft, :submitted, :approved, :refused, :cancelled]
    state_attribute :request_status
    transitions do
      transition :submit, from: :draft, to: :submitted
      transition :approve, from: :submitted, to: :approved
      transition :refuse, from: :submitted, to: :refused
      transition :cancel, from: :submitted, to: :cancelled
      transition :draft, from: :refused, to: :draft
      transition :draft, from: :cancelled, to: :draft
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "approval_request"

    publish :submit, ["approvals.request.submitted"]
    publish :approve, ["approvals.request.approved"]
    publish :refuse, ["approvals.request.refused"]
    publish :cancel, ["approvals.request.cancelled"]
  end
end
