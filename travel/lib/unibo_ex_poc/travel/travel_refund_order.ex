# Workflow: refund_order_lifecycle — 退票单生命周期：审批开启时 pending → approved → refunded / rejected；审批关闭时 pending → refunded
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> approve
#   create --> reject
#   create --> refund_direct
#   approve --> refund
#   reject --> [*] : rejected
#   refund --> [*] : refunded
#   refund_direct --> [*] : refunded
# ```
# Workflow: refund_to_order_cancel — 退票单退款完成后，触发原订单执行 approve_cancel；失败时退票单状态仍保持 refunded（退款已完成，订单取消为最终补偿）
# ```mermaid
# stateDiagram-v2
#   [*] --> refund
#   refund --> [*]
#   approve_cancel --> [*]
# ```
defmodule UniboExPoc.Travel.TravelRefundOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "退票/退订单，记录针对已有 TravelOrder 的退票请求、手续费与退款状态"
  end

  postgres do
    table "travel_refund_orders"
    repo UniboExPoc.Repo
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
      update :approve_travel_travel_refund_order, :approve
      update :reject_travel_travel_refund_order, :reject
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
      description "Create Travel Refund Order via Create. doc_url: graphql://contract/travel/create_travel_travel_refund_order"
      primary? true
      accept [:original_order_id, :refund_reason, :refund_fee, :refund_amount, :approval_mode]
      argument :original_order_id, :uuid, allow_nil?: false
      change manage_relationship(:original_order_id, :original_order, type: :append, on_lookup: :relate)
      validate present(:original_order_id)
    end
    update :approve do
      description "Update Travel Refund Order via Approve. doc_url: graphql://contract/travel/approve_travel_travel_refund_order"
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
      # message: "只有 pending 退票单可以审批或拒绝"
      change set_attribute(:status, :approved)
      change transition_state(:approved)
      require_atomic? false
    end
    update :reject do
      description "Update Travel Refund Order via Reject. doc_url: graphql://contract/travel/reject_travel_travel_refund_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 退票单可以审批或拒绝"
      change set_attribute(:status, :rejected)
      change transition_state(:rejected)
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
      change transition_state(:refunded)
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
      change transition_state(:refunded)
      require_atomic? false
    end

    update :notify_order_refund_approved do
      accept []
      # determination semantics: phase=post_commit, scope=cross_aggregate, mode=async_write_back
      # 异步写回：通过 AsyncRuntime.Queue 进入 outbox 风格队列
      change fn changeset, _ctx ->
        queue_module = UniboExPoc.AsyncRuntime.Queue
        record_id = changeset.data && changeset.data.id
        dedup_key = "determination:travel_refund_order:notify_order_refund_approved:#{inspect(record_id)}"
        payload = %{
          "entity" => "travel_refund_order",
          "determination" => "notify_order_refund_approved",
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
    state_attribute :status
    transitions do
      transition :approve, from: :pending, to: :approved
      transition :reject, from: :pending, to: :rejected
      transition :refund, from: :approved, to: :refunded
      transition :refund_direct, from: :pending, to: :refunded
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "travel_refund_order"

    publish :approve, ["travel.refund_order.approved"]
    publish :reject, ["travel.refund_order.rejected"]
    publish :refund, ["travel.refund_order.refunded"]
    publish :refund_direct, ["travel.refund_order.refunded"]
  end
end
