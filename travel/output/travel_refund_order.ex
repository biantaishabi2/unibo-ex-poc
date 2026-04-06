# Workflow: refund_order_lifecycle — 退票单生命周期：审批开启时 pending → approved → refunded / rejected；审批关闭时 pending → refunded
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> submit
#   create --> refund_direct
#   submit --> confirm_refund
#   submit --> reject_refund
#   confirm_refund --> refund
#   reject_refund --> [*] : rejected
#   refund --> [*] : refunded
#   refund_direct --> [*] : refunded
# ```
defmodule Travel.Travel.TravelRefundOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: Travel.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "退票/退订单，记录针对已有 TravelOrder 的退票请求、手续费与退款状态；审批通过 overlay on Approvals 域"
  end

  postgres do
    table "travel_refund_orders"
    repo Travel.Repo
    identity_index_names unique_order_status: "idx_travel_refund_orders_unique_order_status"
  end

  graphql do
    type :travel_travel_refund_order

    queries do
      get :get_travel_travel_refund_order, :read
      list :list_travel_travel_refund_orders, :read
    end

    mutations do
      create :create_travel_travel_refund_order, :create
      update :update_travel_travel_refund_order, :update
      update :submit_travel_travel_refund_order, :submit
      update :confirm_refund_travel_travel_refund_order, :confirm_refund
      update :reject_refund_travel_travel_refund_order, :reject_refund
      update :refund_travel_travel_refund_order, :refund
      update :refund_direct_travel_travel_refund_order, :refund_direct
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :refund_reason, :string do
      public? true
      description "退票原因"
    end
    attribute :refund_fee, :string do
      public? true
      description "退票手续费"
    end
    attribute :refund_amount, :string do
      public? true
      description "实退金额"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :approved, :refunded, :rejected]
      default :pending
      public? true
    end
    attribute :approval_mode, :atom do
      constraints one_of: [:none, :self, :oa]
      default :self
      public? true
      description "审批模式快照；none 表示跳过审批，self/oa 表示进入审批流"
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
    belongs_to :original_order, Travel.Travel.TravelOrder do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Travel Refund Order via Create. doc_url: graphql://contract/travel/create_travel_travel_refund_order"
      primary? true
      accept [:original_order_id, :refund_reason, :refund_fee, :refund_amount, :approval_mode]
      argument :original_order_id, :uuid, allow_nil?: false
      change manage_relationship(:original_order_id, :original_order, type: :append, on_lookup: :relate)
      validate present(:original_order_id)
    end
    update :update do
      description "Update Travel Refund Order via Update. doc_url: graphql://contract/travel/update_travel_travel_refund_order"
      primary? true
      accept [:refund_reason, :refund_fee, :refund_amount]
      require_atomic? false
    end
    update :submit do
      description "提交退票申请，如 approval_mode=oa 则通过 integration 创建 ApprovalInstance

提交退票申请，如 approval_mode=oa 则通过 integration 创建 ApprovalInstance. doc_url: graphql://contract/travel/submit_travel_travel_refund_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 退票单可以提交或由审批触发"
      change Travel.Travel.Integrations.TravelRefundOrder.SubmitCreateApprovalInstanceBridge
      require_atomic? false
    end
    update :confirm_refund do
      description "Update Travel Refund Order via Confirm Refund. doc_url: graphql://contract/travel/confirm_refund_travel_travel_refund_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 退票单可以提交或由审批触发"
      change set_attribute(:status, :approved)
      change AshStateMachine.BuiltinChanges.transition_state(:approved)
      require_atomic? false
    end
    update :reject_refund do
      description "Update Travel Refund Order via Reject Refund. doc_url: graphql://contract/travel/reject_refund_travel_travel_refund_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 退票单可以提交或由审批触发"
      change set_attribute(:status, :rejected)
      change AshStateMachine.BuiltinChanges.transition_state(:rejected)
      require_atomic? false
    end
    update :refund do
      description "Update Travel Refund Order via Refund. doc_url: graphql://contract/travel/refund_travel_travel_refund_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :approved do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :approved}))
        end
      end
      # message: "只有 approved 退票单可以执行退款"
      change set_attribute(:status, :refunded)
      change AshStateMachine.BuiltinChanges.transition_state(:refunded)
      require_atomic? false
    end
    update :refund_direct do
      description "Update Travel Refund Order via Refund Direct. doc_url: graphql://contract/travel/refund_direct_travel_travel_refund_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :approval_mode)
        if current == :none do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :approval_mode, message: "must equal %{value}", vars: %{value: :none}))
        end
      end
      # message: "只有关闭审批的退票单可以直接退款"
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "关闭审批时，pending 退票单可直接退款"
      change set_attribute(:status, :refunded)
      change AshStateMachine.BuiltinChanges.transition_state(:refunded)
      require_atomic? false
    end
  end

  identities do
    identity :unique_order_status, [:original_order_id, :status]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    belongs_to_actor :user, Travel.Accounts.User, allow_nil?: true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:pending]
    default_initial_state :pending
    extra_states [:pending, :approved, :refunded, :rejected]
    state_attribute :status
    transitions do
      transition :confirm_refund, from: :pending, to: :approved
      transition :reject_refund, from: :pending, to: :rejected
      transition :refund, from: :approved, to: :refunded
      transition :refund_direct, from: :pending, to: :refunded
    end
  end

  pub_sub do
    module Travel.PubSub
    prefix "travel_refund_order"

    publish :submit, ["travel.refund_order.submitted"]
    publish :confirm_refund, ["travel.refund_order.approved"]
    publish :reject_refund, ["travel.refund_order.rejected"]
    publish :refund, ["travel.refund_order.refunded"]
    publish :refund_direct, ["travel.refund_order.refunded"]
  end
end
