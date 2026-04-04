# Workflow: change_order_lifecycle — 改签单生命周期：审批开启时 pending → approved → completed / rejected；审批关闭时 pending → completed
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> submit
#   create --> complete_direct
#   submit --> confirm_change
#   submit --> reject_change
#   confirm_change --> complete
#   reject_change --> [*] : rejected
#   complete --> [*] : completed
#   complete_direct --> [*] : completed
# ```
defmodule Travel.Travel.TravelChangeOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: Travel.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "改签单，记录针对已有 TravelOrder 的改签请求、差价与审批状态；审批通过 overlay on Approvals 域"
  end

  postgres do
    table "travel_change_orders"
    repo Travel.Repo
    identity_index_names unique_order_status: "idx_travel_change_orders_unique_order_status"
  end

  multitenancy do
    strategy :attribute
    attribute :tenant_id
  end

  graphql do
    type :travel_travel_change_order

    queries do
      get :get_travel_travel_change_order, :read
      list :list_travel_travel_change_orders, :read
    end

    mutations do
      create :create_travel_travel_change_order, :create
      update :update_travel_travel_change_order, :update
      update :submit_travel_travel_change_order, :submit
      update :confirm_change_travel_travel_change_order, :confirm_change
      update :reject_change_travel_travel_change_order, :reject_change
      update :complete_travel_travel_change_order, :complete
      update :complete_direct_travel_travel_change_order, :complete_direct
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :tenant_id, :uuid do
      allow_nil? false
      public? true
      description "租户 ID"
    end
    attribute :change_reason, :string do
      public? true
      description "改签原因"
    end
    attribute :price_difference, :string do
      public? true
      description "差价"
    end
    attribute :change_fee, :string do
      public? true
      description "改签手续费"
    end
    attribute :new_offer_id, :string do
      public? true
      description "新报价ID（可能是 FlightOffer/TrainOffer/HotelOffer，不做外键）"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :approved, :completed, :rejected]
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
      description "Create Travel Change Order via Create. Headers: x-tenant-id. doc_url: graphql://contract/travel/create_travel_travel_change_order"
      primary? true
      accept [:original_order_id, :change_reason, :price_difference, :change_fee, :new_offer_id, :approval_mode]
      argument :original_order_id, :uuid, allow_nil?: false
      change manage_relationship(:original_order_id, :original_order, type: :append, on_lookup: :relate)
      validate present(:original_order_id)
    end
    update :update do
      description "Update Travel Change Order via Update. Headers: x-tenant-id. doc_url: graphql://contract/travel/update_travel_travel_change_order"
      primary? true
      accept [:change_reason, :price_difference, :change_fee, :new_offer_id]
      require_atomic? false
    end
    update :submit do
      description "提交改签申请，如 approval_mode=oa 则通过 integration 创建 ApprovalInstance

提交改签申请，如 approval_mode=oa 则通过 integration 创建 ApprovalInstance. Headers: x-tenant-id. doc_url: graphql://contract/travel/submit_travel_travel_change_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 改签单可以提交或由审批触发"
      change Travel.Travel.Integrations.TravelChangeOrder.SubmitCreateApprovalInstanceBridge
      require_atomic? false
    end
    update :confirm_change do
      description "Update Travel Change Order via Confirm Change. Headers: x-tenant-id. doc_url: graphql://contract/travel/confirm_change_travel_travel_change_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 改签单可以提交或由审批触发"
      change set_attribute(:status, :approved)
      change AshStateMachine.BuiltinChanges.transition_state(:approved)
      require_atomic? false
    end
    update :reject_change do
      description "Update Travel Change Order via Reject Change. Headers: x-tenant-id. doc_url: graphql://contract/travel/reject_change_travel_travel_change_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 改签单可以提交或由审批触发"
      change set_attribute(:status, :rejected)
      change AshStateMachine.BuiltinChanges.transition_state(:rejected)
      require_atomic? false
    end
    update :complete do
      description "Update Travel Change Order via Complete. Headers: x-tenant-id. doc_url: graphql://contract/travel/complete_travel_travel_change_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :approved do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :approved}))
        end
      end
      # message: "只有 approved 改签单可以完成"
      change set_attribute(:status, :completed)
      change AshStateMachine.BuiltinChanges.transition_state(:completed)
      require_atomic? false
    end
    update :complete_direct do
      description "Update Travel Change Order via Complete Direct. Headers: x-tenant-id. doc_url: graphql://contract/travel/complete_direct_travel_travel_change_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :approval_mode)
        if current == :none do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :approval_mode, message: "must equal %{value}", vars: %{value: :none}))
        end
      end
      # message: "只有关闭审批的改签单可以直接完成"
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "关闭审批时，pending 改签单可直接完成"
      change set_attribute(:status, :completed)
      change AshStateMachine.BuiltinChanges.transition_state(:completed)
      require_atomic? false
    end
  end

  identities do
    identity :unique_order_status, [:tenant_id, :original_order_id, :status]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    attributes_as_attributes [:tenant_id]
    belongs_to_actor :user, Travel.Accounts.User, allow_nil?: true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:pending]
    default_initial_state :pending
    extra_states [:pending, :approved, :completed, :rejected]
    state_attribute :status
    transitions do
      transition :confirm_change, from: :pending, to: :approved
      transition :reject_change, from: :pending, to: :rejected
      transition :complete, from: :approved, to: :completed
      transition :complete_direct, from: :pending, to: :completed
    end
  end

  pub_sub do
    module Travel.PubSub
    prefix "travel_change_order"

    publish :submit, ["travel.change_order.submitted"]
    publish :confirm_change, ["travel.change_order.approved"]
    publish :reject_change, ["travel.change_order.rejected"]
    publish :complete, ["travel.change_order.completed"]
    publish :complete_direct, ["travel.change_order.completed"]
  end
end
