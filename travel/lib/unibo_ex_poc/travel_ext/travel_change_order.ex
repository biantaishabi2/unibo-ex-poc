# Workflow: change_order_lifecycle — 改签单生命周期：审批开启时 pending → approved → completed / rejected；审批关闭时 pending → completed
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> approve
#   create --> reject
#   create --> complete_direct
#   approve --> complete
#   reject --> [*] : rejected
#   complete --> [*] : completed
#   complete_direct --> [*] : completed
# ```
# Workflow: change_approval_to_order_confirm — 改签审批完成后，触发原订单执行 confirm_change；失败时回滚改签单为 rejected
# ```mermaid
# stateDiagram-v2
#   [*] --> complete
#   complete --> [*]
#   confirm_change --> [*]
# ```
defmodule UniboExPoc.TravelExt.TravelChangeOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.TravelExt,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "改签单，记录针对已有 TravelOrder 的改签请求、差价与审批状态"
  end

  postgres do
    table "travel_ext_travel_change_orders"
    repo UniboExPoc.Repo
    identity_index_names unique_order_status: "idx_travel_ext_travel_change_orders_unique_order_status"
  end

  graphql do
    type :travel_ext_travel_change_order

    queries do
      get :get_travel_ext_travel_change_order, :read
      list :list_travel_ext_travel_change_orders, :read
    end

    mutations do
      create :create_travel_ext_travel_change_order, :create
      update :approve_travel_ext_travel_change_order, :approve
      update :reject_travel_ext_travel_change_order, :reject
      update :complete_travel_ext_travel_change_order, :complete
      update :complete_direct_travel_ext_travel_change_order, :complete_direct
    end

  end

  attributes do
    uuid_primary_key :id
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
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :original_order, UniboExPoc.Travel.TravelOrder do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Travel Change Order via Create. doc_url: graphql://contract/travel_ext/create_travel_ext_travel_change_order"
      primary? true
      accept [:original_order_id, :change_reason, :price_difference, :change_fee, :new_offer_id, :approval_mode]
      argument :original_order_id, :uuid, allow_nil?: false
      change manage_relationship(:original_order_id, :original_order, type: :append, on_lookup: :relate)
      validate present(:original_order_id)
    end
    update :approve do
      description "Update Travel Change Order via Approve. doc_url: graphql://contract/travel_ext/approve_travel_ext_travel_change_order"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 改签单可以审批或拒绝"
      change set_attribute(:status, :approved)
      change AshStateMachine.BuiltinChanges.transition_state(:approved)
      require_atomic? false
    end
    update :reject do
      description "Update Travel Change Order via Reject. doc_url: graphql://contract/travel_ext/reject_travel_ext_travel_change_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 改签单可以审批或拒绝"
      change set_attribute(:status, :rejected)
      change AshStateMachine.BuiltinChanges.transition_state(:rejected)
      require_atomic? false
    end
    update :complete do
      description "Update Travel Change Order via Complete. doc_url: graphql://contract/travel_ext/complete_travel_ext_travel_change_order"
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
      description "Update Travel Change Order via Complete Direct. doc_url: graphql://contract/travel_ext/complete_direct_travel_ext_travel_change_order"
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

    update :notify_order_change_approved do
      accept []
      # determination semantics: phase=post_commit, scope=cross_aggregate, mode=async_write_back
      # 异步写回：通过 AsyncRuntime.Queue 进入 outbox 风格队列
      change fn changeset, _ctx ->
        queue_module = UniboExPoc.AsyncRuntime.Queue
        record_id = changeset.data && changeset.data.id
        dedup_key = "determination:travel_change_order:notify_order_change_approved:#{inspect(record_id)}"
        payload = %{
          "entity" => "travel_change_order",
          "determination" => "notify_order_change_approved",
          "scope" => "cross_aggregate",
          "mode" => "async_write_back",
          "record_id" => record_id
        }
        if Code.ensure_loaded?(queue_module) and function_exported?(queue_module, :enqueue, 1) do
          case queue_module.enqueue(%{kind: "determination_async_write_back", dedup_key: dedup_key, payload: payload}) do
            {:ok, _task} -> changeset
            {:ok, :duplicate} -> changeset
            {:error, reason} -> Ash.Changeset.add_error(changeset, "async determination enqueue failed: #{inspect(reason)}")
          end
        else
          Ash.Changeset.add_error(changeset, "async runtime queue unavailable")
        end
      end
      require_atomic? false
    end
  end

  identities do
    identity :unique_order_status, [:original_order_id, :status]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:pending]
    default_initial_state :pending
    extra_states [:pending, :approved, :completed, :rejected]
    state_attribute :status
    transitions do
      transition :approve, from: :pending, to: :approved
      transition :reject, from: :pending, to: :rejected
      transition :complete, from: :approved, to: :completed
      transition :complete_direct, from: :pending, to: :completed
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "travel_change_order"

    publish :approve, ["travel.change_order.approved"]
    publish :reject, ["travel.change_order.rejected"]
    publish :complete, ["travel.change_order.completed"]
    publish :complete_direct, ["travel.change_order.completed"]
  end
end
