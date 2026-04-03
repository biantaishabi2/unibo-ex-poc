defmodule UniboExPoc.Approvals.Approver do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "审批人记录，跟踪每个审批人对请求的审批状态，支持通过/拒绝/取消/重置"
  end

  postgres do
    table "approvals_approvers"
    repo UniboExPoc.Repo
    identity_index_names unique_user_per_request: "idx_approvals_approvers_unique_user_per_request"
  end

  graphql do
    type :approvals_approver

    queries do
      get :get_approvals_approver, :read
      list :list_approvals_approvers, :read
    end

    mutations do
      create :create_approvals_approver, :create
      update :approve_approvals_approver, :approve
      update :refuse_approvals_approver, :refuse
      update :cancel_approvals_approver, :cancel
      update :reset_pending_approvals_approver, :reset_pending
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :approver_status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :approved, :refused, :cancelled]
      default :pending
      public? true
      description "审批人状态"
    end
    attribute :required, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否为必须审批人"
    end
    attribute :role, :string do
      public? true
      description "审批人角色（如 direct_manager）"
    end
    attribute :comment, :string do
      public? true
      description "审批意见"
    end
    attribute :approval_date, :utc_datetime do
      public? true
      description "做出决定的时间"
    end
    attribute :can_edit, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否可编辑请求内容"
    end
    attribute :sequence_order, :integer do
      public? true
      description "串行审批时的执行顺序"
    end
    attribute :delegation_state, :atom do
      constraints one_of: [:pending, :resolved]
      public? true
      description "委派状态"
    end
    attribute :deadline, :utc_datetime do
      public? true
      description "审批截止时间"
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
    belongs_to :user_party, UniboExPoc.Approvals.Party do
      public? true
      allow_nil? false
    end
    belongs_to :request, UniboExPoc.Approvals.ApprovalRequest do
      public? true
      allow_nil? false
    end
    belongs_to :delegated_from_party, UniboExPoc.Approvals.Party do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Approver via Create. doc_url: graphql://contract/approvals/create_approvals_approver"
      primary? true
      accept [:required, :role, :can_edit, :sequence_order, :user_party_id, :request_id, :delegated_from_party_id]
      argument :user_party_id, :uuid, allow_nil?: false
      change manage_relationship(:user_party_id, :user_party, type: :append, on_lookup: :relate)
      argument :request_id, :uuid, allow_nil?: false
      change manage_relationship(:request_id, :request, type: :append, on_lookup: :relate)
    end
    update :approve do
      description "审批通过

审批通过. doc_url: graphql://contract/approvals/approve_approvals_approver"
      primary? true
      accept [:comment]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :approver_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :approver_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待审批状态可以通过或拒绝"
      change set_attribute(:approver_status, :approved)
      change set_attribute(:approval_date, &DateTime.utc_now/0)
      change AshStateMachine.BuiltinChanges.transition_state(:approved)
      require_atomic? false
    end
    update :refuse do
      description "审批拒绝

审批拒绝. doc_url: graphql://contract/approvals/refuse_approvals_approver"
      accept [:comment]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :approver_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :approver_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待审批状态可以通过或拒绝"
      change set_attribute(:approval_date, &DateTime.utc_now/0)
      change set_attribute(:approver_status, :refused)
      change AshStateMachine.BuiltinChanges.transition_state(:refused)
      require_atomic? false
    end
    update :cancel do
      description "取消（随 request 取消批量设置）

取消（随 request 取消批量设置）. doc_url: graphql://contract/approvals/cancel_approvals_approver"
      accept []
      change set_attribute(:approver_status, :cancelled)
      change AshStateMachine.BuiltinChanges.transition_state(:cancelled)
      require_atomic? false
    end
    update :reset_pending do
      description "重置为待审批（随 request 重置批量设置）

重置为待审批（随 request 重置批量设置）. doc_url: graphql://contract/approvals/reset_pending_approvals_approver"
      accept []
      change set_attribute(:approver_status, :pending)
      change AshStateMachine.BuiltinChanges.transition_state(:pending)
      require_atomic? false
    end
  end

  identities do
    identity :unique_user_per_request, [:request_id, :user_party_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:pending]
    default_initial_state :pending
    extra_states [:pending, :approved, :refused, :cancelled]
    state_attribute :approver_status
    transitions do
      transition :approve, from: :pending, to: :approved
      transition :refuse, from: :pending, to: :refused
      transition :cancel, from: :approved, to: :cancelled
      transition :cancel, from: :refused, to: :cancelled
      transition :reset_pending, from: :cancelled, to: :pending
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "approver"

    publish :approve, ["approvals.approver.approved"]
    publish :refuse, ["approvals.approver.refused"]
    publish :cancel, ["approvals.approver.cancelled"]
    publish :reset_pending, ["approvals.approver.reset"]
  end
end
