defmodule UniboExPoc.Approvals.ApprovalInstance do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "审批实例，承载某个业务单据的审批生命周期与当前步骤状态"
  end

  postgres do
    table "approvals_approval_instances"
    repo UniboExPoc.Repo
    identity_index_names unique_subject_in_template: "idx_approvals_approval_instances_unique_subject_in_template"
  end

  graphql do
    type :approvals_approval_instance

    queries do
      get :get_approvals_approval_instance, :read
      list :list_approvals_approval_instances, :read
    end

    mutations do
      create :create_create_instance_approvals_approval_instance, :create_instance
      update :submit_approvals_approval_instance, :submit
      update :advance_step_approvals_approval_instance, :advance_step
      update :complete_approvals_approval_instance, :complete
      update :mark_rejected_approvals_approval_instance, :mark_rejected
      update :cancel_instance_approvals_approval_instance, :cancel_instance
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string do
      allow_nil? false
      public? true
      description "审批标题"
    end
    attribute :subject_type, :string do
      allow_nil? false
      public? true
      description "业务对象类型（多态引用任何业务实体）"
    end
    attribute :subject_id, :string do
      allow_nil? false
      public? true
      description "业务对象稳定标识"
    end
    attribute :flow_version_no, :integer do
      public? true
      description "本次审批实例绑定的流程版本号"
    end
    attribute :instance_status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :in_progress, :approved, :rejected, :cancelled]
      default :pending
      public? true
      description "审批实例状态"
    end
    attribute :current_step, :integer do
      allow_nil? false
      default 0
      public? true
      description "当前步骤序号，提交后从 1 开始推进"
    end
    attribute :total_steps, :integer do
      allow_nil? false
      default 1
      public? true
      description "总步骤数"
    end
    attribute :request_payload, :map do
      public? true
      description "发起时的业务快照"
    end
    attribute :flow_snapshot, :map do
      public? true
      description "发起时冻结下来的流程节点与路由快照，保证后续版本切换不影响历史实例"
    end
    attribute :route_snapshot, :map do
      public? true
      description "当前审批实例冻结的路由快照，包含审批人解析结果、会签/或签策略与抄送配置"
    end
    attribute :requested_at, :utc_datetime do
      public? true
      description "发起时间"
    end
    attribute :resolved_at, :utc_datetime do
      public? true
      description "审批结束时间"
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
    belongs_to :template, UniboExPoc.Approvals.ApprovalTemplate do
      public? true
      allow_nil? false
    end
    belongs_to :requester_party, UniboExPoc.Approvals.Party do
      public? true
      allow_nil? false
    end
    belongs_to :flow_definition, UniboExPoc.Approvals.ApprovalFlowDefinition do
      public? true
    end
    has_many :todos, UniboExPoc.Approvals.ApprovalTodo do
      public? true
      destination_attribute :instance_id
    end
    has_many :cc_entries, UniboExPoc.Approvals.ApprovalCcEntry do
      public? true
      destination_attribute :instance_id
    end
  end

  actions do
    defaults [:read]
    create :create_instance do
      description "Create Approval Instance via Create Instance. doc_url: graphql://contract/approvals/create_create_instance_approvals_approval_instance"
      primary? true
      accept [:title, :subject_type, :subject_id, :total_steps, :request_payload, :flow_version_no, :flow_snapshot, :route_snapshot, :template_id, :requester_party_id, :flow_definition_id]
      argument :template_id, :uuid, allow_nil?: false
      change manage_relationship(:template_id, :template, type: :append, on_lookup: :relate)
      argument :requester_party_id, :uuid, allow_nil?: false
      change manage_relationship(:requester_party_id, :requester_party, type: :append, on_lookup: :relate)
      validate compare(:total_steps, greater_than_or_equal_to: 1)
      # message: "审批总步骤数至少为 1"
    end
    update :submit do
      description "Update Approval Instance via Submit. doc_url: graphql://contract/approvals/submit_approvals_approval_instance"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :instance_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :instance_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待处理实例可以提交"
      change set_attribute(:instance_status, :in_progress)
      change set_attribute(:requested_at, &DateTime.utc_now/0)
      change set_attribute(:current_step, 1)
      change AshStateMachine.BuiltinChanges.transition_state(:in_progress)
      require_atomic? false
    end
    update :advance_step do
      description "Update Approval Instance via Advance Step. doc_url: graphql://contract/approvals/advance_step_approvals_approval_instance"
      accept [:current_step]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :instance_status)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :instance_status, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中的实例可以流转"
      require_atomic? false
    end
    update :complete do
      description "审批通过（所有步骤完成）

审批通过（所有步骤完成）. doc_url: graphql://contract/approvals/complete_approvals_approval_instance"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :instance_status)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :instance_status, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中的实例可以流转"
      change set_attribute(:instance_status, :approved)
      change set_attribute(:resolved_at, &DateTime.utc_now/0)
      change AshStateMachine.BuiltinChanges.transition_state(:approved)
      require_atomic? false
    end
    update :mark_rejected do
      description "审批拒绝（任一步骤拒绝）

审批拒绝（任一步骤拒绝）. doc_url: graphql://contract/approvals/mark_rejected_approvals_approval_instance"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :instance_status)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :instance_status, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中的实例可以流转"
      change set_attribute(:resolved_at, &DateTime.utc_now/0)
      change set_attribute(:instance_status, :rejected)
      change AshStateMachine.BuiltinChanges.transition_state(:rejected)
      require_atomic? false
    end
    update :cancel_instance do
      description "发起人取消审批

发起人取消审批. doc_url: graphql://contract/approvals/cancel_instance_approvals_approval_instance"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :instance_status)
        if current in [:pending, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :instance_status, message: "must be one of %{values}", vars: %{values: [:pending, :in_progress]}))
        end
      end
      # message: "只有待处理或进行中的实例可以取消"
      change set_attribute(:resolved_at, &DateTime.utc_now/0)
      change set_attribute(:instance_status, :cancelled)
      change AshStateMachine.BuiltinChanges.transition_state(:cancelled)
      require_atomic? false
    end

    update :evaluate_next_step do
      accept []
      # determination semantics: phase=post_commit, scope=same_aggregate, mode=sync_write_back
      validate {UniboExPoc.Approvals.Validations.ApprovalInstance.CheckTodosResolved, []}
      change UniboExPoc.Approvals.Changes.ApprovalInstance.AdvanceOrComplete
      require_atomic? false
    end
  end

  identities do
    identity :unique_subject_in_template, [:template_id, :subject_type, :subject_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:pending]
    default_initial_state :pending
    extra_states [:pending, :in_progress, :approved, :rejected, :cancelled]
    state_attribute :instance_status
    transitions do
      transition :submit, from: :pending, to: :in_progress
      transition :complete, from: :in_progress, to: :approved
      transition :mark_rejected, from: :in_progress, to: :rejected
      transition :cancel_instance, from: :pending, to: :cancelled
      transition :cancel_instance, from: :in_progress, to: :cancelled
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "approval_instance"

    publish :submit, ["approvals.instance.submitted"]
    publish :complete, ["approvals.instance.approved"]
    publish :mark_rejected, ["approvals.instance.rejected"]
    publish :cancel_instance, ["approvals.instance.cancelled"]
  end
end
