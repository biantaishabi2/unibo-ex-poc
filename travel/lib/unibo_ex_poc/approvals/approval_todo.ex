defmodule UniboExPoc.Approvals.ApprovalTodo do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "审批待办记录，跟踪某一步当前分配给谁以及其处理结果"
  end

  postgres do
    table "approvals_approval_todos"
    repo UniboExPoc.Repo
    identity_index_names unique_todo_per_step: "idx_approvals_approval_todos_unique_todo_per_step"
  end

  graphql do
    type :approvals_approval_todo

    queries do
      get :get_approvals_approval_todo, :read
      list :list_approvals_approval_todos, :read
    end

    mutations do
      create :create_create_todo_approvals_approval_todo, :create_todo
      update :approve_approvals_approval_todo, :approve
      update :reject_approvals_approval_todo, :reject
      update :transfer_approvals_approval_todo, :transfer
      update :countersign_approvals_approval_todo, :countersign
      update :cancel_todo_approvals_approval_todo, :cancel_todo
      update :timeout_todo_approvals_approval_todo, :timeout_todo
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :todo_title, :string do
      allow_nil? false
      public? true
      description "待办标题快照"
    end
    attribute :step_index, :integer do
      allow_nil? false
      public? true
      description "待办对应的审批步骤号"
    end
    attribute :approval_policy, :atom do
      allow_nil? false
      constraints one_of: [:single, :all, :any]
      default :single
      public? true
      description "当前步骤的审批策略，single 表示单人，all 表示会签，any 表示或签"
    end
    attribute :route_source, :atom do
      allow_nil? false
      constraints one_of: [:static, :flow, :manual_reassign, :manual_add_sign]
      default :static
      public? true
      description "当前待办的路由来源"
    end
    attribute :todo_status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :approved, :rejected, :transferred, :cancelled, :timed_out]
      default :pending
      public? true
      description "待办处理状态"
    end
    attribute :decision_comment, :string do
      public? true
      description "审批意见或系统备注"
    end
    attribute :routing_snapshot, :map do
      public? true
      description "当前待办冻结的审批人解析快照、组织关系依据与抄送信息"
    end
    attribute :assigned_at, :utc_datetime do
      public? true
      description "分派时间"
    end
    attribute :acted_at, :utc_datetime do
      public? true
      description "处理时间"
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
    belongs_to :instance, UniboExPoc.Approvals.ApprovalInstance do
      public? true
      allow_nil? false
    end
    belongs_to :assignee_party, UniboExPoc.Approvals.Party do
      public? true
      allow_nil? false
    end
    belongs_to :completed_by_party, UniboExPoc.Approvals.Party do
      public? true
    end
    belongs_to :transferred_from_todo, UniboExPoc.Approvals.ApprovalTodo do
      public? true
    end
    has_many :transferred_to_todos, UniboExPoc.Approvals.ApprovalTodo do
      public? true
      source_attribute :transferred_from_todo_id
      destination_attribute :transferred_from_todo_id
    end
  end

  actions do
    defaults [:read]
    create :create_todo do
      description "Create Approval Todo via Create Todo. doc_url: graphql://contract/approvals/create_create_todo_approvals_approval_todo"
      primary? true
      accept [:todo_title, :step_index, :approval_policy, :route_source, :routing_snapshot, :instance_id, :assignee_party_id, :transferred_from_todo_id]
      argument :instance_id, :uuid, allow_nil?: false
      change manage_relationship(:instance_id, :instance, type: :append, on_lookup: :relate)
      argument :assignee_party_id, :uuid, allow_nil?: false
      change manage_relationship(:assignee_party_id, :assignee_party, type: :append, on_lookup: :relate)
      validate compare(:step_index, greater_than_or_equal_to: 1)
      # message: "待办步骤号至少为 1"
      change set_attribute(:todo_status, :pending)
      change set_attribute(:assigned_at, &DateTime.utc_now/0)
    end
    update :approve do
      description "Update Approval Todo via Approve. doc_url: graphql://contract/approvals/approve_approvals_approval_todo"
      primary? true
      accept [:decision_comment, :completed_by_party_id]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :todo_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :todo_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待处理待办可以流转"
      change set_attribute(:todo_status, :approved)
      change set_attribute(:acted_at, &DateTime.utc_now/0)
      change AshStateMachine.BuiltinChanges.transition_state(:approved)
      require_atomic? false
    end
    update :reject do
      description "Update Approval Todo via Reject. doc_url: graphql://contract/approvals/reject_approvals_approval_todo"
      accept [:decision_comment, :completed_by_party_id]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :todo_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :todo_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待处理待办可以流转"
      change set_attribute(:acted_at, &DateTime.utc_now/0)
      change set_attribute(:todo_status, :rejected)
      change AshStateMachine.BuiltinChanges.transition_state(:rejected)
      require_atomic? false
    end
    update :transfer do
      description "转签给其他审批人

转签给其他审批人. doc_url: graphql://contract/approvals/transfer_approvals_approval_todo"
      accept [:decision_comment, :assignee_party_id]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :todo_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :todo_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待处理待办可以流转"
      change set_attribute(:acted_at, &DateTime.utc_now/0)
      change set_attribute(:todo_status, :transferred)
      change AshStateMachine.BuiltinChanges.transition_state(:transferred)
      require_atomic? false
    end
    update :countersign do
      description "加签，新增审批人

加签，新增审批人. doc_url: graphql://contract/approvals/countersign_approvals_approval_todo"
      accept [:decision_comment, :assignee_party_id]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :todo_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :todo_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待处理待办可以流转"
      change set_attribute(:acted_at, &DateTime.utc_now/0)
      change set_attribute(:route_source, :manual_add_sign)
      require_atomic? false
    end
    update :cancel_todo do
      description "Update Approval Todo via Cancel Todo. doc_url: graphql://contract/approvals/cancel_todo_approvals_approval_todo"
      accept [:decision_comment]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :todo_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :todo_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待处理待办可以流转"
      change set_attribute(:acted_at, &DateTime.utc_now/0)
      change set_attribute(:todo_status, :cancelled)
      change AshStateMachine.BuiltinChanges.transition_state(:cancelled)
      require_atomic? false
    end
    update :timeout_todo do
      description "Update Approval Todo via Timeout Todo. doc_url: graphql://contract/approvals/timeout_todo_approvals_approval_todo"
      accept [:decision_comment]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :todo_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :todo_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待处理待办可以流转"
      change set_attribute(:acted_at, &DateTime.utc_now/0)
      change set_attribute(:todo_status, :timed_out)
      change AshStateMachine.BuiltinChanges.transition_state(:timed_out)
      require_atomic? false
    end
  end

  identities do
    identity :unique_todo_per_step, [:instance_id, :step_index, :assignee_party_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:pending]
    default_initial_state :pending
    extra_states [:pending, :approved, :rejected, :transferred, :cancelled, :timed_out]
    state_attribute :todo_status
    transitions do
      transition :approve, from: :pending, to: :approved
      transition :reject, from: :pending, to: :rejected
      transition :transfer, from: :pending, to: :transferred
      transition :cancel_todo, from: :pending, to: :cancelled
      transition :timeout_todo, from: :pending, to: :timed_out
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "approval_todo"

    publish :approve, ["approvals.todo.approved"]
    publish :reject, ["approvals.todo.rejected"]
    publish :transfer, ["approvals.todo.transferred"]
    publish :countersign, ["approvals.todo.countersigned"]
    publish :timeout_todo, ["approvals.todo.timed_out"]
    publish :cancel_todo, ["approvals.todo.cancelled"]
  end
end
